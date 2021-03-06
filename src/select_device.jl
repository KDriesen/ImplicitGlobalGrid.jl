export select_device

import MPI
@static if ENABLE_CUDA
    using CUDA
end

"""
    select_device()

Select the device (GPU) corresponding to the node-local MPI rank and return its ID. This function only needs to be called when using nodes with more than one device.
"""
function select_device()
    check_initialized();
    @static if ENABLE_CUDA
        @assert CUDA.functional(true)
        comm_l = MPI.Comm_split_type(comm(), MPI.MPI_COMM_TYPE_SHARED, me())
    	if (MPI.Comm_size(comm_l) > length(CUDA.devices())) error("More processes have been launched per node than there are GPUs available."); end
    	me_l = MPI.Comm_rank(comm_l)
        CUDA.device!(me_l)
        return me_l
    else
        error("Cannot select a GPU because ImplicitGlobalGrid was not precompiled for GPU usage (as CUDA was not functional).")
    end
end
