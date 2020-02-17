struct CompiledForward{T<:AbstractTape} <: AbstractTape
    tape::T
    forward_exec::Vector{FunctionWrapper{Nothing, Tuple{}}}
end

Base.show(io::IO, t::CompiledForward) = print(io, typeof(t).name, "($(t.tape.func))")

function CompiledForward(t::T) where T<:AbstractTape
    CompiledForward{T}(t, [FunctionWrapper{Nothing, Tuple{}}(ForwardExecutor(instruction)) for instruction in t.tape])
end

Base.length(ct::CompiledForward) = length(ct.tape)

@inline func_hook(ct::CompiledForward) = func_hook(ct.tape)

@inline input_hook(ct::CompiledForward) = input_hook(ct.tape)

@inline output_hook(ct::CompiledForward) = output_hook(ct.tape)

function forward_pass!(compiled_tape::CompiledForward)
    for wrapper in compiled_tape.forward_exec
        wrapper()
    end
    nothing
end

function compile(f, args...)
    tp = GradientTape(f, (args))
    cp = CompiledForward(tp)
end

value(x::TrackedArray) = x.value
value(x::Tuple) = value.(x)
value(x) = x

function (tp::CompiledForward)(in...)
  ReverseDiff.seeded_forward_pass!(tp, in)
  tp.tape.output |> value
end
