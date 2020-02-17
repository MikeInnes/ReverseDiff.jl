# ReverseDiff

[ReverseDiff](https://github.com/JuliaDiff/ReverseDiff.jl), patched to expose the package's tracing function compiler (which is independent of AD) in a more easy-to-use way. The compiler can work with Julia code that doesn't need AD, or even code that uses a different AD.

```julia
julia> using ReverseDiff: compile

julia> f(a, b) = sum(a' * b + a * b')
f (generic function with 1 method)

julia> input = rand(100, 100), rand(100, 100);

julia> cf = compile(f, input...)
ReverseDiff.CompiledForward(f)

julia> cf(input...)
497216.0510064624
```

```julia
julia> using Zygote

julia> g(a, b) = Zygote.gradient(f, a, b)
g (generic function with 1 method)

julia> cg = compile(g, input...)
ReverseDiff.CompiledForward(g)

julia> cg(input...)
([101.53 101.37 …
```

Note the caveats of this approach: chiefly that control flow is not supported. The function you trace will effectively be run once with the example inputs you give, and any control flow is frozen at that point. Also, the function inputs and outputs should consistent of arrays or tuples of arrays.
