struct Trace
  timestamps :: Vector{Float64}
  payloads :: Vector{Int64}
end

struct Workload
  τ :: Float64
  probs :: Vector{Float64}
  services :: Vector{Float64}
  function Workload(tr::Trace, τ::Float64, capacity::Float64)
    payloadtimes = Dict{Int64, Float64}()
    i = 1
    j = 1
    payload = 0
    while τ >= tr.timestamps[i]
      payload += tr.payloads[i]
      i += 1
    end
    timeₜ = tr.timestamps[end]
    timestamps = [tr.timestamps..., (tr.timestamps[1:i] .+ timeₜ)...]
    payloads = [tr.payloads..., tr.payloads[1:i]...]
    time = τ
    timeᵢ = timestamps[i]
    timeⱼ = timestamps[j] + τ
    timeₛ = timeₜ + τ
    while true
      #@show time timeᵢ timeⱼ timeₛ payload
      if timeₛ <= timeᵢ && timeₛ <= timeⱼ
        payloadtimes[payload] = get(payloadtimes, payload, 0) + timeₛ - time
        break
      end
      if timeⱼ <= timeᵢ
        payloadtimes[payload] = get(payloadtimes, payload, 0) + timeⱼ - time
        payload -= payloads[j]
        time = timeⱼ
        j += 1
        timeⱼ = timestamps[j] + τ
      else
        payloadtimes[payload] = get(payloadtimes, payload, 0) + timeᵢ - time
        payload += payloads[i]
        time = timeᵢ
        i += 1
        timeᵢ = timestamps[i]
      end
    end
    probs = Float64[]
    services = Float64[]
    for (payload, time) in payloadtimes
      push!(probs, time / timeₜ)
      push!(services, payload / capacity)
    end
    @show probs services
    new(τ, probs, services)
  end
end

function rate(work::Workload, θ::Float64, v::Float64)
  mgf = 0.0
  for (prob, service) in zip(work.probs, work.services)
    mgf += prob * exp(θ * service)
  end
  θ * (work.τ + v) - log(mgf)
end

function drate(work::Workload, θ::Float64, v::Float64)
  mgf = 0.0
  dmgf = 0.0
  ddmgf = 0.0
  for (prob, service) in zip(work.probs, work.services)
    tmp = prob * exp(θ * service)
    mgf += tmp
    dmgf += service * tmp
    dmgf += service^2 * tmp
  end
  work.τ + v - dmgf / mgf,
end
