svg=".svg"
png=".png"

while getopts s:n: option
do
        case "${option}"
        in
                n) NAME=${OPTARG};;
        esac
done

let "SIZE=40"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png

let "SIZE=60"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png

let "SIZE=58"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png

let "SIZE=80"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png

let "SIZE=87"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png

let "SIZE=120"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png

let "SIZE=180"
qlmanage -t -s $SIZE -o . $NAME$svg
mv $NAME$svg$png $NAME"-"$SIZE$png
