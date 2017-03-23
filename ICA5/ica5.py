import cv2

vc = cv2.VideoCapture(0)

if vc.isOpened():
    print("vc is open!!")
    return_value, frame = vc.read()

h_range = 159
h2_range = 93
key = -1
while key != 27 and vc.isOpened():
    return_value, frame = vc.read()

    if frame is not None:

        height, width, depth = frame.shape

        frame = cv2.pyrDown(frame)

        hsv_img = cv2.cvtColor(frame, cv2.COLOR_BGR2HSV)
        hsv_img = cv2.flip( hsv_img, 1 )
        h, s, v = cv2.split(hsv_img)

        h_copy = h.copy()

        h = cv2.inRange(h, h_range, h_range+10)
        h_binary = h.copy()

        h2 = cv2.inRange(h_copy, h2_range, h2_range+10)
        h2_binary = h2.copy()

        _, contours, hierarchy = cv2.findContours(h_binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

        if contours is not None and len(contours) > 0:
            for cnt in contours:
                area = cv2.contourArea(cnt)
                # bb   = cv2.boundingRect(cnt)


                if area > 300:
                    pt = tuple(cnt[0][0])
                    (x,y),radius = cv2.minEnclosingCircle(cnt)
                    cv2.circle(hsv_img, (int(x),int(y)), int(radius)+2, (255,0,255), 2)
                    cv2.putText(hsv_img, str(area), pt, cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255,255,255))


        _, contours2, hierarchy2 = cv2.findContours(h2_binary, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

        if contours2 is not None and len(contours2) > 0:
            for cnt in contours2:
                area = cv2.contourArea(cnt)
                # bb   = cv2.boundingRect(cnt)


                if area > 300:
                    pt = tuple(cnt[0][0])
                    (x,y),radius = cv2.minEnclosingCircle(cnt)
                    cv2.circle(hsv_img, (int(x),int(y)), int(radius)+2, (255,0,0), 2)
                    cv2.putText(hsv_img, str(area), pt, cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255,255,255))


        cv2.putText(h, str(h_range), (10, 100), cv2.FONT_HERSHEY_SIMPLEX, 1, 128)
        # cv2.imshow("WebCam", frame)
        cv2.imshow("Hue", hsv_img)

    key = cv2.waitKey(10)

    print("key: ",key)
    if key == 0:
        h_range += 1
    elif key == 1:
        h_range -= 1
