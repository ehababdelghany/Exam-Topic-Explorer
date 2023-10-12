read -p "Enter exam link ex :https://www.examtopics.com/discussions/hashicorp/ :" EXAM_LINK_ADD
#EXAM_LINK_ADD="https://www.examtopics.com/discussions/amazon/"
read -p "Enter exam name ex :exam-terraform-associate :" EXAM_NAME
#EXAM_NAME="solutions-architect-associate"
read -p "Enter patch start page: " PATCH_START
read -p "Enter patch end page: " PATCH_END
echo "starting from ${PATCH_START} to ${PATCH_END}"


mkdir failed
mkdir all
ALL_FOLDER="$(pwd)/all"

for (( VARIABLE=$PATCH_START; VARIABLE<=$PATCH_END; VARIABLE++ ))
do
    PAGE_NUMBER=$VARIABLE
    EXAM_LINK="${EXAM_LINK_ADD}${PAGE_NUMBER}/"
    echo $PAGE_NUMBER
    mkdir ${PAGE_NUMBER}
    cd ${PAGE_NUMBER}
    pwd
    sleep 2
    #change link
    echo $EXAM_LINK
    curl $EXAM_LINK |grep '<a href="/discussions/' >wget_run.sh
    #change exam name
    cat wget_run.sh  |grep -i $EXAM_NAME >wget.temporary
    sleep 2
    cat wget.temporary > wget_run.sh
    sleep 2
    rm -rf wget.temporary
    sed -i 's+<a href="+\n sleep 2 \n wget -np -r -k https://www.examtopics.com+g' wget_run.sh
    sleep 2
    sed -i 's+/"+/+g' wget_run.sh
    sleep 2
    echo "find . -name index.html -type f -exec cat {} + > page_${PAGE_NUMBER}.html " >>wget_run.sh
    sleep 2
    chmod 755 wget_run.sh
    cat wget_run.sh
    sleep 2
    ./wget_run.sh >> ../failed/failed.logs 2>&1

#remove header
    sed -i '' -e '/<div class="full-width-header">/,/<!-- Menu End -->/d' page_${PAGE_NUMBER}.html
#remove footer
    sed -i '' -e '/<!-- Footer Start -->/,/<!-- Footer End -->/d' page_${PAGE_NUMBER}.html
#remove duplicate functions
        sed -i '0,/<!-- start scrollUp  -->/{s@<!-- start scrollUp  -->@<!-- start scffrollUp  -->@}' page_${PAGE_NUMBER}.html
    sed -i '0,/<!-- End temporary -->/{s@<!-- End temporary -->@<!-- End final temporary -->@}' page_${PAGE_NUMBER}.html
    sed -i '' -e '/<!-- start scrollUp  -->/,/<!-- End temporary -->/d' page_${PAGE_NUMBER}.html
#remove unlimited box
    sed -i '' -e '/<div class="sec-spacer pt-50">/,/<!-- BEGIN Discussions header \/ title -->/d' page_${PAGE_NUMBER}.html
        sed -i 's@<!-- discussion-page.html -->@<div class="sec-spacer pt-50">\n<div class="container">@g' page_${PAGE_NUMBER}.html


    cp -f page_${PAGE_NUMBER}.html $ALL_FOLDER
    cd ..
    pwd

done
# run failed ones


cd failed
failed=$(cat *.logs |grep -B 4 "ERROR 503: Service Unavailable." |grep discussions |awk '{print $3}' |wc -l)
echo "failed downloads: ${failed}"

while [ $failed -ne 0 ];
do
        failed=$(cat *.logs |grep -B 4 "ERROR 503: Service Unavailable." |grep discussions |awk '{print $3}' |wc -l)
        echo "failed downloads: ${failed}"
        cat failed.logs |grep -B 4 "ERROR 503: Service Unavailable." |grep discussions |awk '{print $3}' >>wget_failed.sh
        :> failed.logs
        sed -i 's+https+\n sleep 3 \n wget -np -r -k https+g' wget_failed.sh
        echo "find . -name index.html -type f -exec cat {} + > page_failed.html " >>wget_failed.sh
        chmod 755 wget_failed.sh
        ./wget_failed.sh >> failed.logs 2>&1
        :> wget_failed.sh
done


sed -i '' -e '/<div class="full-width-header">/,/<!-- Menu End -->/d' page_failed.html
#remove footer
sed -i '' -e '/<!-- Footer Start -->/,/<!-- Footer End -->/d' page_failed.html
#remove duplicate functions
sed -i '0,/<!-- start scrollUp  -->/{s@<!-- start scrollUp  -->@<!-- start scffrollUp  -->@}' page_failed.html
sed -i '0,/<!-- End temporary -->/{s@<!-- End temporary -->@<!-- End final temporary -->@}' page_failed.html
sed -i '' -e '/<!-- start scrollUp  -->/,/<!-- End temporary -->/d' page_failed.html
#remove unlimited box
sed -i '' -e '/<div class="sec-spacer pt-50">/,/<!-- BEGIN Discussions header \/ title -->/d' page_failed.html
sed -i 's@<!-- discussion-page.html -->@<div class="sec-spacer pt-50">\n<div class="container">@g' page_failed.html

cp -f page_failed.html $ALL_FOLDER
