using WANPerformanceAnalyzer
using Plots

@show minimum(diff([1.0, 2.0, 3.0, 4.0]))
tr = Trace([1.0, 2.0, 3.0, 4.0], [3, 0, 0, 0])
c = 1.0
τ = 1.0
v = 0.5
cgf = CGF(tr, τ, c)
θ = collect(-2.0:0.1:2.0)
plot(θ, map(t -> rate(cgf, t, v), θ))
plot!(θ, map(t -> drate(cgf, t, v), θ))
