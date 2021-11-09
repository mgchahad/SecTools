#!/bin/bash
if [ "$1" == "" ]; then
    echo "Please, set the domain as a parameter!"
    echo "How to use: ./check_domain.sh DOMAIN"
    echo "Example: ./check_domain.sh businesscorp.com.br"
else
    for url in "$1"; do wget -q "$url" ; done
    grep  href index.html | cut -d "/" -f 3 | grep "\." | cut -d '"' -f 1 | grep -v "<l" > lista
    rm index.html
    for lista in $(cat lista); do host "$lista" | grep "has address"; done
    rm lista
fi
