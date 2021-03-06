@recipe function f(b::FullBinner{T}) where T<:Number
    framestyle --> :grid
    size --> (750, 500)
    plottype = get(plotattributes, :seriestype, :plot)

    if plottype == :histogram
        @series begin
            color --> :lightblue
            alpha --> 0.6
            label --> ""
            legend --> true
            b.x
        end
    elseif plottype == :binning
        bss, errors, error_means = BinningAnalysis.all_binning_errors(b)
        @series begin
            label --> "standard error"
            seriestype := :line
            markershape --> :circle
            markercolor --> :lightgreen
            markersize --> 2
            color --> :lightgreen
            legend --> true
            bss, errors
        end

        @series begin
            seriestype := :line
            xlabel --> "bin sizes"
            label --> "cumulative mean"
            ylabel --> "standard error of the mean"
            markershape --> :circle
            markercolor --> :green
            markersize --> 2
            color --> :green
            legend --> true
            bss, error_means
        end
    elseif plottype == :corrplot
        y = autocor(b.x)
        @series begin
            seriestype := :line
            markershape --> :circle
            markercolor --> :blue
            markersize --> 2
            color --> :blue
            y
        end

        @series begin
            seriestype := :line
            xlabel --> "lag"
            ylabel --> "autocorrelation"
            legend --> false
            color --> :grey
            linestyle --> :dash
            ylim --> (min(minimum(y),0), 1.1)
            fill(0, length(y))
        end
    elseif plottype == :tauplot
        bss, errors, error_means = BinningAnalysis.all_binning_errors(b)
        taus = tau.(Ref(b), errors)
        @series begin
            seriestype := :line
            xlabel --> "bin sizes"
            label --> "autocorrelation time"
            markershape --> :circle
            markercolor --> :lightblue
            markersize --> 2
            color --> :blue
            bss, taus
        end

        @series begin
            tau_means = [mean(@view taus[1:i]) for i in 1:length(taus)]
            seriestype := :line
            xlabel --> "bin sizes"
            label --> "cumulative mean"
            ylabel --> "autocorrelation time"
            markershape --> :circle
            markercolor --> :blue
            markersize --> 2
            color --> :green
            legend --> true
            bss, tau_means
        end
    else
        @series begin
            xlabel --> "time t"
            label --> "time series"
            markershape --> :circle
            markercolor --> :grey
            markersize --> 2
            color --> :grey
            legend --> true
            b.x
        end
    end

    μ = mean(b)
    if plottype == :histogram
        @series begin
            seriestype := :vline
            color --> :black
            label --> "mean"
            fill(μ, length(b))
        end
    elseif plottype in (:binning, :corrplot, :tauplot)
        nothing
    else
        @series begin
            seriestype := :hline
            color --> :purple
            label --> "mean"
            fill(μ, length(b))
        end
    end

    Δ = std_error(b)
    if !(plottype in (:binning, :corrplot, :tauplot))
        for i in (1, -1)
            @series begin
                seriestype := (plottype == :histogram ? :vline : :hline)
                color --> :violet
                label --> (i == 1 ? "std error" : "")
                fill(μ + i*Δ, length(b))
            end
        end
    end
end

@shorthands binning
@shorthands corrplot
@shorthands tauplot





# ---------------------- LogBinner -----------------------
@recipe function f(b::LogBinner{T}) where T<:Number
    framestyle --> :grid
    size --> (750, 500)
    plottype = get(plotattributes, :seriestype, :plot)

    if plottype == :tauplot
        taus = all_taus(b)
        bss = 2 .^ (2:length(taus)+1)
        idxs = findall(bs->bs<=length(b)/30, bss)
        taus = taus[idxs]
        bss = bss[idxs]
        @series begin
            seriestype := :line
            xlabel --> "bin sizes"
            label --> "autocorrelation time"
            markershape --> :circle
            markercolor --> :lightblue
            markersize --> 2
            color --> :blue
            bss, taus
        end

        @series begin
            tau_means = [mean(@view taus[1:i]) for i in 1:length(taus)]
            seriestype := :line
            xlabel --> "bin sizes"
            label --> "cumulative mean"
            ylabel --> "autocorrelation time"
            markershape --> :circle
            markercolor --> :blue
            markersize --> 2
            color --> :green
            legend --> true
            bss, tau_means
        end
    elseif plottype == :corrplot
        y = autocor(b.x_sum)
        @series begin
            seriestype := :line
            markershape --> :circle
            markercolor --> :blue
            markersize --> 2
            color --> :blue
            y
        end

        @series begin
            xlabel --> "lag"
            ylabel --> "autocorrelation (of log bin means!)"
            seriestype := :line
            color --> :grey
            linestyle --> :dash
            ylim --> (min(minimum(y),0), 1.1)
            legend --> false
            fill(0, length(y))
        end
    elseif plottype == :binning
        errors = all_std_errors(b)
        bss = 2 .^ (2:length(errors)+1)
        idxs = findall(bs->bs<=length(b)/30, bss)
        bss = bss[idxs]
        errors = errors[idxs]
        error_means = [mean(errors[1:i]) for i in 1:length(errors)] # TODO: optimize
        @series begin
            label --> "standard error"
            seriestype := :line
            markershape --> :circle
            markercolor --> :lightgreen
            markersize --> 2
            color --> :lightgreen
            legend --> true
            bss, errors
        end

        @series begin
            seriestype := :line
            xlabel --> "bin sizes"
            label --> "cumulative mean"
            ylabel --> "standard error of the mean"
            markershape --> :circle
            markercolor --> :green
            markersize --> 2
            color --> :green
            legend --> true
            bss, error_means
        end
    end
end
