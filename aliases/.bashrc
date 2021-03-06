mygcc() {
        gcc -x c -Wall -std=c99 -O2 -static -pipe -o $1 "$1.c" -lm 
}

mygpp() {
        g++ -x c++ -Wall -std=c++14 -O2 -static -pipe -o $1 "$1.cpp" -lm 
}

myjavac() {
        javac -encoding UTF-8 -d . $1
}

myjava() {
        java -Xrs -Xss64m -Xmx1572864k $1
}
