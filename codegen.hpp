#pragma once
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include "node.hpp"
#include "parser.hpp"

// generate the js code to output file, based on a program node
extern void codeGenPro(nodeType* p);