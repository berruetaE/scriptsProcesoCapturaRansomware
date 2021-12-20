#!/bin/bash

	bytesToHuman() {
		b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
		while ((b > 1000)); do
		    d="$(printf ".%02d" $((b % 1000 * 100 / 1000)))"
		    b=$((b / 1000))
		    let s++
		done
		echo "$b$d ${S[$s]}"
	}
