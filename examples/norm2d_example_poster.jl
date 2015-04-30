using ABCDistances
using Distributions
using PyPlot

######################################################################
##Define plotting functions
######################################################################
plot_cols = ("b", "g", "r", "c", "m", "y", "k")
function plot_init(out::ABCSMCOutput, i::Int32)
    ssim = out.init_sims[i]
    n = min(500, size(ssim)[2])
    s1 = vec(ssim[1,1:n])
    s2 = vec(ssim[2,1:n])
    plot(s1, s2, ".", color=plot_cols[i])
end
function plot_acc(out::ABCSMCOutput, i::Int32)
    w = out.abcdists[i].w
    h = out.thresholds[i]
    ##Plot appropriate ellipse
    θ = [0:0.1:6.3]
    x = (h/w[1])*sin(θ)+sobs[1]
    y = (h/w[2])*cos(θ)+sobs[2]
    plot(x, y, lw=3, color=plot_cols[i])
end

######################################################################
##EXAMPLE 1: one informative summary statistic
######################################################################
##Set up abcinput
function sample_sumstats(pars::Array)
    success = true
    stats = [pars[1] + 0.1*randn(1), randn(1)]
    (success, stats)
end

sobs = [0.0,0.0]

abcinput = ABCInput();
abcinput.prior = MvNormal(1, 100.0);
abcinput.sample_sumstats = sample_sumstats;
abcinput.abcdist = MahalanobisDiag(sobs);
abcinput.sobs = sobs;
abcinput.nsumstats = 2;

##Perform ABC-SMC
srand(20)
smcoutput1 = abcSMC(abcinput, 10000, 1000, 250000, store_init=true);
srand(20)
smcoutput2 = abcSMC(abcinput, 10000, 1000, 250000, adaptive=true, store_init=true);

##Look at weights
smcoutput1.abcdists[1].w
[smcoutput2.abcdists[i].w for i in 1:smcoutput2.niterations]

##Plot simulations from each importance density and acceptance regions
nits = min(smcoutput1.niterations, smcoutput2.niterations)
PyPlot.figure(figsize=(22,4))
PyPlot.subplot(221)
for i in 1:nits
    plot_init(smcoutput1, i)
end
PyPlot.axis([-300,300,-4,4])
PyPlot.xlabel(L"$s_1$")
PyPlot.ylabel(L"$s_2$")
PyPlot.title("Non-adaptive simulations")
PyPlot.subplot(222)
for i in 1:nits
    plot_init(smcoutput2, i)
end
PyPlot.axis([-300,300,-4,4])
PyPlot.xlabel(L"$s_1$")
PyPlot.ylabel(L"$s_2$") 
PyPlot.title("Adaptive simulations")
PyPlot.subplot(223)
for i in 1:nits
    plot_acc(smcoutput1, i)
end
PyPlot.xlabel(L"$s_1$")
PyPlot.ylabel(L"$s_2$")
PyPlot.title("Non-adaptive acceptance regions")
PyPlot.subplot(224)
for i in 1:nits
    plot_acc(smcoutput2, i)
end
PyPlot.xlabel(L"$s_1$")
PyPlot.ylabel(L"$s_2$")
PyPlot.title("Adaptive acceptance regions")
PyPlot.tight_layout();
PyPlot.savefig("normal_acc_regions_poster.pdf")