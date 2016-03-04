
function function_name () {
    list of commands
    [ return value ]
}

函数返回值，可以显式增加return语句；如果不加，会将最后一条命令运行结果作为返回值。



Shell 函数返回值只能是整数，一般用来表示函数执行成功与否，0表示成功，其他值表示失败。



$unset .f function_name




调用函数只需要给出函数名，不需要加括号。



