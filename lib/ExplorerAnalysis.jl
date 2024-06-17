module ExplorerAnalysis

    using CPIDataGT
    CPIDataGT.load_data()

    using DataFrames
    using DataFramesMeta

    export cpi_data, cpi_bases
    export get_series, subsetdf

    const cpi_bases = ["IPC base 2000", "IPC base 2010", "IPC base 2023"]
    const cpi_data = Dict(2000 => FGT00, 2010 => FGT10, 2023 => FGT23)

    function _get_op(op)
        if op == :index 
            return identity
        elseif op == :mmchange 
            return varinterm 
        elseif op == :yychange 
            return varinteran
        end
    end

    function get_series(base, product, op)
        # Get the FullCPIBase corresoponding to the selected base
        fullbase = cpi_data[base]
        # Get transformation for selection
        f = _get_op(op) 
        # Find the index in the FullCPIBase
        i = findfirst(==(product), fullbase.names)

        # Get the appropiately transformed data 
        ts = f(fullbase.ipc[:, i])
        dates = fullbase.dates

        if length(ts) < length(dates)
            nmissings = length(dates) - length(ts)
            ts = [missings(nmissings); ts]
        end
        df = DataFrame(date=dates, series=ts)
        df
    end

    function subsetdf(df, date0, date1)
        subdf = @rsubset(df, :date >= date0 && :date <= date1)
        subdf
    end
end
