subroutine indyns
    ! subroutine indyns
    !
    ! Purpose : set time-stepping constants and initialize coefficients
    !           and spectral operators for model dynamics

    use mod_dyncon0
    use physical_constants, only: grav, rgas
    use params
    use mod_hdifcon, only: dmp, dmpd, dmps, tcorv, qcorv
    use geometry, only: fsg

    implicit none

    integer :: j, k, npowhd
    real :: elap, elapn, hdifd, hdiff, hdifs, qexp, rgam, rlap, twn

    ! 1. Definition of constants
    if (mod(nsteps,2) /= 0) stop ' Invalid no. of time steps'

    ! Power of Laplacian in horizontal diffusion
    npowhd = 4

    ! Coefficients for horizontal diffusion
    ! Spectral damping coefficients
    hdiff = 1./(thd *3600.)
    hdifd = 1./(thdd*3600.)
    hdifs = 1./(thds*3600.)
    rlap  = 1./float(trunc*(trunc+1))

    do j = 1, nx
        do k = 1, mx
            twn = float(k +j - 2)
            elap = (twn*(twn+1.)*rlap)
            elapn = elap**npowhd
            dmp(k,j)  = hdiff*elapn
            dmpd(k,j) = hdifd*elapn
            dmps(k,j) = hdifs*elap
        end do
        ! dmps(1,j)=0.
    end do

    ! 5.2 Orographic correction terms for temperature and humidity
    !     (vertical component)
    rgam = rgas*gamma/(1000.*grav)
    qexp = hscale/hshum

    tcorv(1)=0.
    qcorv(1)=0.
    qcorv(2)=0.

    do k = 2, kx
        tcorv(k) = fsg(k)**rgam
        if (k.gt.2) qcorv(k) = fsg(k)**qexp
    end do
end
