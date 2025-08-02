local debug = true  -- toggle debug prints

return {
    debugPrint = function(...)
        if not debug then return end

        lib.print.info(...)
    end
}