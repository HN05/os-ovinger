## What do you have to do before you can run your C program? In other words, which steps do you have to repeat if you change anything in your code so that the code produces a new output?
You have to compile and link it.


## As we highlighted in the exercise lecture, the compiler is your friend. With what can the compiler help you? Which things can the compiler not help you with? Which other tools can you use if the compiler cannot provide support?
The compiler can help with syntax errors and very simple logical errors. It can not help you with complex logical errors, in that case you can use debuggers


## Scenario: After you start your program, it runs for a few seconds before it crashes. The only output to the console immediately before the crash is SEGFAULT. Which tools could be useful to debug such an error?
You can use a debugger to see where it happens and in which instances it occurs. Valgrind could also be useful here


## Pointer arithmetic : A pointer is a special type of variable that contains an address that points to a memory location. As with any normal variable, you can apply operations to the value stored in a pointer variable, but it has some minor differences in behaviour.

```c
struct point
{
    int x;
    int y;
    int z;
};

int main()
{
	struct point pArray[4] = {{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}};
	pArray[1].z = 1025;
	int *i = (int *)(pArray + 1);
	*i = 4;
	i = (int *)(((void *)i) + 9);
	char *c = (char *)i;
	printf("c: %d\n", *c);
	*((int *)(c + 4) + 1) = 5;
	printf("%d\n", pArray[2].y);
}
```

### a) Which values does pArray store after line 10 was executed? What values would it be without the part after the =?
It stores 12 ints in succession organized into point structs. Without the part after the = the values stored would be garbage
### b) On line 13, where is the 4 stored? Is this a valid storage location, or are we touching storage that has not been allocated?
The 4 is stored in the x-value of the second point struct. When you do pArray + 1 you get the address of the second point struct, and when typcasting to *int it will point to the first int in the point struct, which is the x-value
### c) What will be printed on line 16?
On line 14 you are doing pointer arithmetic on a void* which is illegal in many compilers, so there is a good chance the program would crash before executing the line. If you use a compiler that allows it, then it will treat it as a char*, and so it will advance the pointer i by 9 bytes. It then points to the second byte of the int that was stored 1025 into on line 11, assuming each int is 32 bits. What it prints out now depends on the endianness of the system it is running on which determines in what order it stores LSB to MSB. I assume it is running on a little-endian system, which means that the LSB is stored in the lowest memory address. 1025 is 0000 0100 0000 0001 in binary, i would then point to 0000 0100 which would print out the number 4
### d) What will be printed on line 18?
First it will advance pointer c by 4 bytes which is equivalent to one int, so it now points to the second byte of pArray\[2\].x then it casts the pointer to a int* and adds one, so it advances by another int and now points to the second byte of pArray\[2\].y and puts the value 5 into it, so replacing the second byte with 1010 which effectively becomes left shifted with 8 bits so now the value of the int is 2^8 + 2^10 = 1280, so that is what will be printed out on line 18
### e) What would be the result of the following snippet? Explain your solution. Would it be different if we cast i to a short? Assume 32-bit integers (=4 bytes).
```c
int *i = 0;
unsigned long diff = (unsigned long)(i + 2) - (unsigned long)i;
printf("%lx\n", diff);
```
i is a int* with memory address of 0, then i is added with 2 and then becomes 8, since the size of int in bytes is 4, then it subtracts 0 and that will be the value of diff. It then prints it out in hex which is still just 8. If i was cast to a short instead of an int then the answer would be 4 since short is 2 bytes. If it was cast to short instead of long, then nothing would change


## 2. Practical examples

The output of the program is 'Hello World' if no args are passed, but if one or more args are passed, then it says hello to the first argument, so 'Hello {arg} nice to meet you'
