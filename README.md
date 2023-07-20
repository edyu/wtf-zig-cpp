# Zig C/C++ Compiler -- WTF is Zig C++

The power and complexity of **Zig CC** and **Zig C++ ** in Zig

---

Ed Yu ([@edyu](https://github.com/edyu) on Github and
[@edyu](https://twitter.com/edyu) on Twitter)
Jul.20.2023

---

![Zig Logo](https://ziglang.org/zig-logo-dark.svg)

## Introduction

[**Zig**](https://ziglang.org) is a modern systems programming language and although it claims to a be a **better C**, many people who initially didn't need systems programming were attracted to it due to the simplicity of its syntax compared to alternatives such as **C++** or **Rust**.

However, due to the power of the language, some of the syntaxes are not obvious for those first coming into the language. I was actually one such person.

Today we will explore Zig as a **C/C++** programmer and see how the **Zig** compiler can be used as a **C/C++** compiler. The idea of the post came from a [talk](https://www.youtube.com/watch?v=-XLSyaJ6m3o) I gave to the [*Bay Area C++ Group*](https://www.meetup.com/cpp-bay-area/).

Because the [talk](https://www.youtube.com/watch?v=-XLSyaJ6m3o) was presented to a mostly **C++** group that may have never heard of **Zig**, the deck was ridiculously long. In response, the purpose of this blog is to only focus on using **Zig** as a **C/C++** toolchain rather than as a language.

## Zig Toolchain

If you go to the [**Zig** website](https://ziglang.org/), you'll see the following quote:

> Zig is a general-purpose programming language and toolchain for maintaining robust, optimal and reusable software.

What I found interesting when I first read it was that it added the words *and toolchain*.

And if you go further down as on the page, you'll see a particular section focused on **C/C**:

> Incrementally improve your C/C++/Zig codebase.
    * Use Zig as a zero-dependency, drop-in C/C++ compiler that supports cross-compilation out-of-the-box.
    * Leverage zig build to create a consistent development environment across all platforms.
    * Add a Zig compilation unit to C/C++ projects; cross-language LTO is enabled by default.
    
For those who don't know (and I had to look it up myself), *LTO* stands for *Link-Time Optimization*.

To summarize, **Zig** can be used as a **C/C++** compiler that has great cross-compilation support and is optimized by default.

## Zig as a C Compiler

Let's start with a simple **C** program -- [*Hello World*](https://www.programiz.com/c-programming/examples/print-sentence):

```c
#include <stdio.h>
int main() {
  // printf() displays the string inside quotation
  printf("Hello, World!\n");
  return 0;
}
```

Let's compile it using the **Zig** toolchain by calling `zig cc`:

```bash
zig cc hello.c -o "hello-c"
./hello-c
```

It works!

## Zig as a C++ Compiler

Now Let's do the same with a **C++** program -- [*Hello World*](https://www.programiz.com/cpp-programming/examples/print-sentence)

```cpp
// Your First C++ Program

#include <iostream>

int main() {
  std::cout << "Hello World!";
  return 0;
}
```

Similar to `zig cc`, **Zig** can compile **C++** programs by calling `zig c++`:

```bash
zig c++ hello.cpp -o "hello-cpp"
./hello-cpp
```

It works too!

## Zig as a C Cross-Compiler

If you specify a `-target`, you can cross compile to any target that **Zig** supports.
For example, because I develop on *Ubuntu* on a *Windows* laptop using *WSL*, it's easy for me to test the *Windows* cross compilation.

In my *WSL*, I can do the following:

```bash
zig cc hello.c -o "hello-c.exe" -target x86_64-windows
```

I then copy over the file to *Windows* from my *WSL*:

```bash
cp hello-c.exe /mnt/c/Users/edlyu/Downloads/
```

Finally, I can run the program on my *Windows Terminal*:

```bash
cd Downloads
.\hello-c.exe
```

## Zig as a C++ Cross-Compiler

For **C++**, the only difference is replacing `zig cc` with `zig c++`

```bash
zig c++ hello.cpp -o "hello-cpp.exe" -target x86_64-windows
```

Copy over the file to *Windows*:

```bash
cp hello-cpp.exe /mnt/c/Users/edlyu/Downloads/
```

Run the program:

```bash
cd Downloads
.\hello-cpp.exe
```

## Zig Cross-Compilation

The **Zig Toolchain** is used at Uber for compiling and cross-compiling the **Go** monorepo. The initial motivation was to support the *arm64* hardware.

Motiejus Jakštys wrote a great article on how the **Zig** toolchain is used in Uber at this [blog post](https://www.uber.com/blog/bootstrapping-ubers-infrastructure-on-arm64-with-zig/) and his [talk](https://www.youtube.com/watch?v=SCj2J3HcEfc). He had another update earlier this year, but it hasn't been updated yet.

One of the reasons why **Zig** is so suitable for cross-compilation is because it bundles *libC* in source form so not only can one **Zig** toolchain used for cross-compilation for many targets but also the toolchain size is very small.

As of writing, **Zig** supports about 40+ *OS* and *ABI* targets, and 60+ *arch* targets. In addition, if you need *libC* support, there are also about 60 target architectures that bundles *libC*.

You can see all the targets yourself by running `zig targets`.

## Zig Toolchain Example

As an example, I wanted to compile something slightly more complicated than *Hello World*, so I decided to compile [*gRPC*](https://github.com/grpc/grpc) which is mostly written in **C++** using the **Zig** toolchain.

The *gRPC* example is moderately complicated because it has 20+ dependencies that are built together.

One of the complications I encountered was that *gRPC* uses [*Bazel*](https://bazel.build/) or [*CMake*](https://cmake.org/). I decided to use *CMake* for this example.

What I found is that if you decide to use **Zig** toolchain to build a **C++** library you'll need to build both the library and the code that uses the library with the **Zig** toolchain. In other words, you cannot build the **C++** library first and then only use the **Zig** toolchain for the code that uses the library.

On my *WSL*, I was able to build the main *gRPC* library using the following commands:

```bash
CC="zig cc -mcrc32" CXX="zig c++ -mcrc32" cmake \ 
  -DgRPC_INSTALL=ON \
  -DgRPC_BUILD_TESTS=OFF \ 
  -DOPENSSL_NO_ASM=ON \
  -DCMAKE_INSTALL_PREFIX=/home/edyu/.env \
  ../..

make -j 4
make
```

Make sure you replace `CMAKE_INSTALL_PREFIX` with where you'd prefer to install the *gRPC* library locally.

I had to include `-mcrc32` and set `-DOPENSSL_NO_ASM=ON` to make it work on my *WSL* whereas if I didn't use the *Zig* toolchain, I didn't need to.

After the *gRPC* library itself was built and installed, I then run the following commands to build the examples:

```bash
CC="zig cc" CXX="zig c++" cmake -DCMAKE_PREFIX_PATH=/home/edyu/.env ../..
make -j 4
```

Make sure you replace `CMAKE_PREFIX_PATH` with the same location you set in `CMAKE_INSTALL_PREFIX` earlier.

For me, on my *WSL* I was able to build the *gRPC* library, compile against the library, and the compiled programs worked.


## Importing C++ Library using Build.Zig

For those of you who are not familiar with *build.zig*, you can read my previous [blog post](https://zig.news/edyu/zig-package-manager-wtf-is-zon-558e).

Basically, *build.zig* allows you to describe the build process using *Zig* code itself instead of resorting to something like a *Makefile*. The benefit is so that a **Zig** programmer doesn't need to context-switch to another file format or build language such as *Makefile*.

Here is a more complex example of [build.zig](https://github.com/kimmolinna/duckdb-zig-build/blob/master/build.zig) file used to build [DuckDB](https://duckdb.org/), another **C++** library.

We now talk about exporting your **C++** library to **Zig** code.

Let's write a simple *Hello World* library in C++ and call it using *Zig*. The following example is based upon a [*StackOverflow* answer](https://stackoverflow.com/questions/73467232/how-to-incorporate-the-c-standard-library-into-a-zig-program).

Because there is no default binding in **C++** in **Zig**, we'll have to write our own binding.

In the following example, our function is directly defined inside the binding function but in a more realistic example, you'll write binding functions that call your library functions after importing them just like how `std::cout` is imported via `<iostream>`.

```cpp
#include <iostream>

extern "C" void helloWorld(void) {
  std::cout << "Hello world!";
}
```

Note that we are converting our **C++** function to **C** convention.

We also need the header file and because **Zig** has much better support for **C**, we need the **C** header file:

```c
void helloWorld(void);
```

And finally, we need to call our **C/C++** function:

```zig
const std = @import("std");
const cpp = @cImport({
    @cInclude("hello.h");
});

pub fn main() !void {
    cpp.helloWorld();
}
```

Now, let's first define the build process in our `build.zig`:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "helloworld",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // link with the standard library libcpp
    exe.linkLibCpp();
    exe.addIncludePath("src");
    exe.addCSourceFile("src/hello.cpp", &.{});

    b.installArtifact(exe);
}
```

Build and run the program:

```bash
zig build
./zig-out/bin/helloworld
```

Viola, it worked!

## Package Manager

The previous **C++** library `build.zig` example is extremely simple in that everything is defined in one file.

In general, in best practice, you'll likely separate your **C++** library and binding from the code that calls the library. In fact, you may even write a wrapper in **Zig** and separate that from the main code.

For that to work, you'll need to utilize the new *Package Manager*. You can read about how to do so in my [previous blog post](https://zig.news/edyu/zig-package-manager-wtf-is-zon-558e).

## Bonus

Instead of `zig cc`, you can also build a **C** program and link to *libC* with the following command:

```bash
zig build-exe hello.c --library c
./hello
```

You can do the same for **C++**; instead of calling `zig c++`:

```bash
zig build-exe hello.cpp --library c++
./hello
```

Run the command `zig libc` to see where the native *libC* files.

There is also a `zig translate-c` that can be useful if you are converting your **C** code to **Zig** but it's fairly complex due to the number of options it gives you.

## The End

You can also read the [blog post](https://andrewkelley.me/post/zig-cc-powerful-drop-in-replacement-gcc-clang.html) about using `zig cc` by Andrew Kelley himself.

You can find the code [here](https://github.com/edyu/wtf-zig-cpp).

Special thanks to [Matheus França](https://github.com/kassane) for helping out on **C++** build question!

## ![Zig Logo](https://ziglang.org/zero.svg)
