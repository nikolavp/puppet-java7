#!/bin/bash
# vim: set sw=4 sts=4 et foldmethod=indent :

ls -1 /usr/lib/jvm/java-7-oracle/bin | while read alternative;do
    /usr/sbin/update-alternatives --install "/usr/bin/${alternative}" "${alternative}" "/usr/lib/jvm/java-7-oracle/bin/${alternative}" 1
done
