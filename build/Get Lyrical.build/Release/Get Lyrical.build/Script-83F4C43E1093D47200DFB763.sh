#!/bin/sh

rm -r Get\ Lyrical
mkdir -p Get\ Lyrical
cp -r Read\ Me.html Get\ Lyrical/Read\ Me.html
cp -r build/Release/Get\ Lyrical.app Get\ Lyrical/
ditto -c -k --sequesterRsrc --keepParent Get\ Lyrical/ getlyrical.zip
