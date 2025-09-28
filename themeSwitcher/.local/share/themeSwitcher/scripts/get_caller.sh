#!/bin/bash

# Get called environment
if [ -t 1 ]; then
	CALLER="Terminal"
else
	CALLER="Launcher"
fi
