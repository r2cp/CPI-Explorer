module Explorer

using GenieFramework
using Main.ExplorerAnalysis
import PlotlyBase
using PlotlyBase: scatter 
using Dates
using Statistics: mean
using DataFrames: DataFrame

@genietools

@app begin
    @out trace = [scatter()]
    @out layout = PlotlyBase.Layout(
        yaxis_title="Índice de precios",
        yaxis2_title="Variación porcetual (%)",
        yaxis2_overlaying = "y",
        yaxis2_side = "right",
    )
    # Plotly events
    @in data_click = Dict{String,Any}()
    @in data_hover = Dict{String,Any}()
    @in data_selected = Dict{String,Any}()      # Only with box and lasso selection
    @in data_cursor = Dict{String,Any}()        # When finished movement in axis
    @in data_relayout = Dict{String,Any}()

    @private df = DataFrame(date=Date[], series=Float32[])
    @out table_data = DataTable(DataFrame(date = Date[], series = Float32[]))
    
    @in select_base = 2000
    @out opts = cpi_data[2000].names 
    @in select_product = [cpi_data[2000].names[1]]
    @in select_op = [:index]
    @in button_process = false

    @onchange select_base begin
        base = select_base
        opts = cpi_data[base].names
        select_product = [opts[1]]
    end

    @onchange data_relayout begin
        # @show data_relayout
        ks  = keys(data_relayout)

        x0k = "xaxis.range[0]"
        x1k = "xaxis.range[1]"

        # Get dates from range and filter DataFrame
        if x0k in ks && x1k in ks
            d0, d1 = data_relayout[x0k], data_relayout[x1k]
            date0 = split(d0, " ") |> first |> Date |> firstdayofmonth
            date1 = split(d1, " ") |> first |> Date |> lastdayofmonth
            @info "Date range selection" date0 date1
            subdf = subsetdf(df, date0, date1)
            table_data = DataTable(subdf)
        end

        xar = "xaxis.autorange"
        if xar in ks 
            # @show xar
            @info "Date range reset"
            table_data = DataTable(df)
        end
    end

    @onbutton button_process begin

        # Get DataFrame with series
        base = select_base
        product = first(select_product)
        op = first(select_op)
        # @info "Operation" op typeof(op)

        df = get_series(base, product, op)

        # Update plot 
        if op != :index 
            nt = scatter(x=df.date, y=df.series, name=product, yaxis="y2")
        else
            nt = scatter(x=df.date, y=df.series, name=product) 
        end
        trace = [nt]

        # Update table
        table_data = DataTable(df)
    end

end

function ui()
    [
        row(h2("Explorador de series del IPC")),
        row([
            cell(class="col-md-3", [
                select(:select_base, options = [2000, 2010, 2023], label = "Base del IPC"),
                select(:select_product, options = :opts, label = "Producto"),
                select(:select_op, 
                    options = [
                        # (op=:index,    val="Índice"), 
                        # (op=:mmchange, val="Variación intermensual (%)"), 
                        # (op=:yychange, val="Variación interanual (%)")
                        :index,
                        :mmchange,
                        :yychange,
                    ], 
                    # optionvalue="op",
                    # optionlabel="val",
                    label = "Transformación"
                ),
                separator(color="primary"),
                h6("Opciones", color="primary", class="col-md-auto"),
                btn("Graficar", @click(:button_process), color="green"),
            ]),
            cell(class="", [
                plot(:trace, layout=:layout, class="sync_data"),
                table(:table_data, flat = true, bordered = true, title = "Datos"),
            ]),
        ])
    ]
end

@mounted watchplots()

@page("/", ui)

end