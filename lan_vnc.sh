#!/bin/bash

vncviewer -FullScreen=0 -PasswordFile=$HOME/.vnc/passwd -AutoSelect -PreferredEncoding=Tight -NoJPEG -MenuKey=Pause "$@"
