module m_read_field2d

contains


 subroutine read_field2d(fbase,char8,field,idm,jdm,indxl,undef,maxcoord)
! Routine which read instantanous fields. Both a and b files are used in the reading process.
   use mod_za , only: zaiopf, zaiord, zaiocl, zaiosk
   implicit none
   integer,         intent(in)  :: idm,jdm !i,j,k coordinates
   integer,         intent(in)  :: indxl 
   character(len=80),intent(in) :: fbase
   character(len=8), intent(in) :: char8
   real*4,          intent(out) :: field(idm,jdm)
   real*4,        intent(inout) :: undef
   integer, optional,intent(in) :: maxcoord

   logical,parameter :: skiphdr=.true.
   integer           :: nop,ios
   integer           :: maxco
   logical           :: match


   character(len=5)  :: char5
   character(len=8)  :: cfld
   character(len=80) :: fullstring, fname
   real*4            :: amax,amin,bmin,bmax
   integer           :: lcoord
   real*4            :: fld4(idm,jdm)
   if (present(maxcoord)) then
      maxco=maxcoord
   else
      maxco=-1
   end if

   if (indxl>0) then
      fname=trim(fbase)//'.a'
      call readraw(fld4,amax,amin,idm,jdm,.false.,undef,fname,indxl)
      field=fld4
   else
      field=0;
   endif

end subroutine

! Modified from Alan Wallcraft's RAW routine by Knut Liseter @ NERSC
! So far only the "I" in "IO" is present
SUBROUTINE READRAW(A,AMN,AMX,IDM,JDM,LSPVAL,SPVAL,CFILE1,K)
   IMPLICIT NONE
!
   REAL*4     SPVALH
   PARAMETER (SPVALH=1.0E30_4)
!
   REAL*4,        INTENT(OUT) :: A(IDM,JDM)
   REAL*4,        INTENT(OUT) :: AMN,AMX
   INTEGER,       INTENT(IN)  :: IDM,JDM
   LOGICAL,       INTENT(IN)  :: LSPVAL
   REAL*4,        INTENT(INOUT)  :: SPVAL
   INTEGER,       INTENT(IN)  :: K
   CHARACTER(len=*), INTENT(IN)  :: CFILE1
!
   REAL*4 :: PADA(4096)
!
!     MOST OF WORK IS DONE HERE.

   INTEGER      LEN_TRIM
   INTEGER      I,J,IOS,NRECL
   INTEGER      NPAD,nop
!
   IF(.NOT.LSPVAL) THEN
     SPVAL = SPVALH
   ENDIF
!
!!! Calculate the number of elements padded!!!!!!!!!!!!!!!!!!!!!!!!
   NPAD=GET_NPAD(IDM,JDM)
!
   print *, trim(CFILE1), ' rec=', K
   INQUIRE( IOLENGTH=NRECL) A,PADA(1:NPAD)
!     
!     
   nop=101
   OPEN(UNIT=nop, FILE=trim(CFILE1), FORM='UNFORMATTED', STATUS='old', & 
     ACCESS='DIRECT', RECL=NRECL, IOSTAT=IOS, ACTION='READ')
   IF     (IOS.NE.0) THEN
     write(6,*) 'Error: can''t open ',CFILE1(1:LEN_TRIM(CFILE1))
     write(6,*) 'ios   = ',ios, IDM, JDM
     write(6,*) 'nrecl = ',nrecl
     CALL EXIT(3)
   ENDIF
!
     write(6,*) 'ios   = ',ios, IDM, JDM
     write(6,*) 'nrecl = ',nrecl,K
   READ(nop,REC=K,IOSTAT=IOS) A
   close(nop)
!
   IF     (IOS.NE.0) THEN
     WRITE(6,*) 'can''t read record ',K, &
          ' from '//CFILE1(1:LEN_TRIM(CFILE1))
     write(6,*) 'ios   = ',ios, IDM, JDM
     write(6,*) 'nrecl = ',nrecl
     CALL EXIT(4)
   ENDIF
!
   AMN =  SPVALH
   AMX = -SPVALH
   DO J= 1,JDM
      DO I=1,IDM
         IF     (A(I,J).LE.SPVALH) THEN
            AMN = MIN(real(AMN, 4), real(A(I,J), 4))
            AMX = MAX(real(AMX, 4), real(A(I,J), 4))
         ELSEIF (LSPVAL) THEN
            A(I,J) = SPVAL
         ENDIF
      END DO
   END DO
!                 
   RETURN
   END SUBROUTINE



      INTEGER FUNCTION GET_NPAD(IDM,JDM)
      IMPLICIT NONE
      INTEGER, INTENT(IN) :: IDM,JDM
         GET_NPAD = 4096 - MOD(IDM*JDM,4096)
         GET_NPAD = mod(GET_NPAD,4096)
      END FUNCTION


end module

