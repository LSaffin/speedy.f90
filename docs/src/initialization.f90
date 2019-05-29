!> author: Sam Hatfield, Fred Kucharski, Franco Molteni
!  date: 08/05/2019
!  The master initialization module.
module initialization
    implicit none

    private
    public initialize

contains
    !> Initializes everything.
    subroutine initialize
        use params, only: issty0
        use date, only: newdate, model_datetime, start_datetime, end_datetime, isst0
        use coupler, only: initialize_coupler
        use sea_model, only: sea_coupling_flag, sst_anomaly_coupling_flag
        use geometry, only: initialize_geometry
        use spectral, only: initialize_spectral
        use geopotential, only: initialize_geopotential
        use horizontal_diffusion, only: initialize_horizontal_diffusion
        use physics, only: initialize_physics
        use input_output, only: output
        use time_stepping, only: first_step
        use boundaries, only: initialize_boundaries
        use prognostics, only: initialize_prognostics
        use forcing, only: set_forcing

        call print_speedy_title

        ! Read start and end dates from fort.2 file
        read (2,*) start_datetime%year
        read (2,*) start_datetime%month
        read (2,*) start_datetime%day
        read (2,*) start_datetime%hour
        read (2,*) start_datetime%minute
        read (2,*) end_datetime%year
        read (2,*) end_datetime%month
        read (2,*) end_datetime%day
        read (2,*) end_datetime%hour
        read (2,*) end_datetime%minute
        model_datetime = start_datetime

        ! Initialize date
        call newdate(0)

        write(*,'(A12,I4,A,I0.2,A,I0.2,A,I0.2,A,I0.2)') 'Start date: ', &
            & start_datetime%year,'/',start_datetime%month,'/',start_datetime%day,' ', &
            & start_datetime%hour,':',start_datetime%minute
        write(*,'(A12,I4,A,I0.2,A,I0.2,A,I0.2,A,I0.2)') 'End date: ', &
            & end_datetime%year,'/',end_datetime%month,'/',end_datetime%day,' ', &
            & end_datetime%hour,':',end_datetime%minute

        ! Initialize month index for reading SST anomaly file
        isst0 = (start_datetime%year - issty0) * 12 + start_datetime%month

        ! Check consistency of coupling and prescribed SST anomaly flags
        if (sea_coupling_flag >= 4) sst_anomaly_coupling_flag = 1

        ! =========================================================================
        ! Initialization of atmospheric model constants and variables
        ! =========================================================================

        ! Initialize model geometry
        call initialize_geometry

        ! Initialize spectral transforms
        call initialize_spectral

        ! Initialize geopotential calculations
        call initialize_geopotential

        ! Initialize horizontal diffusion
        call initialize_horizontal_diffusion

        ! Initialize constants for physical parametrization
        call initialize_physics

        ! Initialize boundary conditions (land-sea mask, sea ice etc.)
        call initialize_boundaries

        ! Initialize model variables
        call initialize_prognostics

        ! =========================================================================
        ! Initialization of coupled modules (land, sea, ice)
        ! =========================================================================

        call initialize_coupler

        ! =========================================================================
        ! Initialization of first time step
        ! =========================================================================

        ! Set up the forcing fields for the first time step
        call set_forcing(0)

        ! Do the initial (2nd-order) time step, initialize the semi-implicit scheme
        call first_step
    end subroutine

    !> Prints SPEEDY.f90 banner.
    subroutine print_speedy_title
        write (*,'(A)') ''
        write (*,'(A)') '  _____ ______  _____  _____ ______ __   __     __  _____  _____'
        write (*,'(A)') ' /  ___|| ___ \|  ___||  ___||  _  \\ \ / /    / _||  _  ||  _  |'
        write (*,'(A)') ' \ `--. | |_/ /| |__  | |__  | | | | \ V /    | |_ | |_| || |/  |'
        write (*,'(A)') '  `--. \|  __/ |  __| |  __| | | | |  \ /     |  _|\____ ||  /| |'
        write (*,'(A)') ' /\__/ /| |    | |___ | |___ | |/ /   | |   _ | |  .___/ /\ |_/ /'
        write (*,'(A)') ' \____/ \_|    \____/ \____/ |___/    \_/  (_)|_|  \____/  \___/'
        write (*,'(A)') ''
    end subroutine
end module