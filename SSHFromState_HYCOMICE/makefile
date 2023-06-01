MPI = NO

include ./make.inc
VPATH = .:RCS:TMP

.SUFFIXES:
.SUFFIXES: .o .F90 .f90 .F .f .H .h .c

# Rules for running cpp and updating files in TMP directory
.H.h:
	rm -f ./TMP/$*.h
	cat MODEL.CPP $*.H | $(CPP) $(CPPFLAGS)  > ./TMP/$*.h


.F90.o:
	rm -f ./TMP/$*.f90
	cat MODEL.CPP $*.F90 | $(CPP) $(CPPFLAGS)   > ./TMP/$*.f90
	cd ./TMP ; $(CF90) -c $(FFLAGS) $(F90FLG) -o $*.o $*.f90  

.F.o:
	rm -f ./TMP/$*.f
	cat MODEL.CPP $*.F | $(CPP) $(CPPFLAGS)  > ./TMP/$*.f
	cd ./TMP ; $(CF77) -c $(FFLAGS) $(F77FLG) -o $*.o $*.f  

.c.o:
	rm -f ./TMP/$*.c
	cat MODEL.CPP $*.c | $(CPP) $(CPPFLAGS)   >  ./TMP/$*.c
	cd ./TMP ; $(CC) -c $(CFLAGS)  -o $*.o $*.c

OBJECTS_SSH_FROM_RESTART =\
nfw.o\
mod_xc.o\
mod_za.o\
mod_sigma.o\
mod_year_info.o\
m_year_day.o\
m_datetojulian.o\
mod_read_rstab.o\
m_parse_blkdat.o\
p_ssh_from_state.o\
wtime.o\
machine.o\
machi_c.o

OBJECTS_RESTART2NC =\
nfw.o\
mod_xc.o\
mod_za.o\
mod_sigma.o\
mod_year_info.o\
m_year_day.o\
m_datetojulian.o\
mod_read_rstab.o\
m_parse_blkdat.o\
mod_ice_io.o\
mod_read_icednc.o\
p_restart2nc.o\
wtime.o\
machine.o\
machi_c.o

OBJECTS_RESTART3 =\
mod_xc.o\
mod_za.o\
wtime.o\
m_read_field2d.o\
p_extract_ssh.o


all: ssh_from_restart restart2nc extract2ssh

ssh_from_restart: $(OBJECTS_SSH_FROM_RESTART)  
	cd ./TMP ; $(LD) $(LINKFLAGS) -o ../ssh_from_restart $(OBJECTS_SSH_FROM_RESTART) $(LIBS) 

restart2nc: $(OBJECTS_RESTART2NC)  
	cd ./TMP ; $(LD) $(LINKFLAGS) -o ../restart2nc $(OBJECTS_RESTART2NC) $(LIBS) 

extract2ssh: $(OBJECTS_RESTART3)  
	cd ./TMP ; $(LD) $(LINKFLAGS) -o ../extract2ssh $(OBJECTS_RESTART3) $(LIBS) 

clean:
	cd ./TMP ; rm *.f  *.o *.f90 *.h *.mod

mod_sigma.o: stmt_fns_SIGMA0.h
mod_sigma.o: stmt_fns_SIGMA2.h
mod_sigma.o: stmt_fns_SIGMA4.h
