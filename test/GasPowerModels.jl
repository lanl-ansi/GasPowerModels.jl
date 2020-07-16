@testset "src/GasPowerModels.jl" begin
    @testset "silence" begin
        # This should silence everything except error messages.
        GasPowerModels.silence()

        # Ensure the the InfrastructureModels logger is silenced.
        im_logger = Memento.getlogger(_IM)
        @test Memento.getlevel(im_logger) == "error"
        Memento.warn(im_logger, "Silenced message should not be displayed.")

        # Ensure the the PowerModels logger is silenced.
        pm_logger = Memento.getlogger(_PM)
        @test Memento.getlevel(pm_logger) == "error"
        Memento.warn(pm_logger, "Silenced message should not be displayed.")

        # Ensure the the GasModels logger is silenced.
        gm_logger = Memento.getlogger(_GM)
        @test Memento.getlevel(gm_logger) == "error"
        Memento.warn(gm_logger, "Silenced message should not be displayed.")
    end
end
