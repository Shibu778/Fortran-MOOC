program resesrvoir_sampling
    use, intrinsic :: iso_fortran_env, only : error_unit, iostat_end
    implicit none
    integer :: unit_nr, istat, reservoir_size, val, i, j
    integer, dimension(:), allocatable :: reservoir
    real :: r
    character(len=1024) :: file_name, msg

    call get_arguments(file_name, reservoir_size)

    ! allocate the reservoir
    allocate(reservoir(reservoir_size), stat=istat)
    if (istat /= 0) then
        write (unit=error_unit, fmt='(A)') 'error: can not allocate reservoir'
        stop 3
    end if

    ! open file for direct access
    open (newunit=unit_nr, file=trim(file_name), form='formatted', &
          status='old', action='read', access='direct', recl=10, &
          iostat=istat, iomsg=msg)
    if (istat /= 0) then
        write (unit=error_unit, fmt='(2A)') 'error: ', msg
        stop 2
    end if

    ! fill initial reservoir
    do i = 1, size(reservoir)
        read (unit=unit_nr, fmt='(I10)', rec=i, iostat=istat, iomsg=msg) &
            reservoir(i)
        if (istat /= 0) exit
    end do

    ! continue with the remainder of the file
    i = reservoir_size + 1
    do
        read (unit=unit_nr, fmt='(I10)', rec=i, iostat=istat, iomsg=msg) val
        if (istat /= 0) exit
        call random_number(r)
        j = 1 + floor(r*i)
        if (j <= size(reservoir)) reservoir(j) = val
        i = i + 1
    end do

    close (unit_nr)

    ! print sample
    do i = 1, size(reservoir)
        print '(I10)', reservoir(i)
    end do

contains

    subroutine get_arguments(file_name, reservoir_size)
        implicit none
        character(len=*), intent(out) :: file_name
        integer, intent(out) :: reservoir_size
        integer :: istat
        character(len=1024) :: buffer, msg

        if (command_argument_count() /= 2) then
            write (unit=error_unit, fmt='(A)') &
                'error: expecting file name and reservoir size'
            stop 1
        end if
        call get_command_argument(1, file_name)
        call get_command_argument(2, buffer)
        read (buffer, '(I10)', iostat=istat, iomsg=msg) reservoir_size
        if (istat /= 0) then
            write (unit=error_unit, fmt='(2A)') 'error: ', trim(msg)
            stop 2
        end if
    end subroutine get_arguments

end program resesrvoir_sampling
