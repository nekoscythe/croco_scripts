! $Id: cppdefs.h 1628 2015-01-10 13:53:00Z marchesiello $
!
!======================================================================
! CROCO is a branch of ROMS developped at IRD and INRIA, in France
! The two other branches from UCLA (Shchepetkin et al)
! and Rutgers University (Arango et al) are under MIT/X style license.
! CROCO specific routines (nesting) are under CeCILL-C license.
!
! CROCO website : http://www.croco-ocean.org
!======================================================================
!
/*
   This is "cppdefs.h": MODEL CONFIGURATION FILE
   ==== == ============ ===== ============= ====
*/

#define REGIONAL        /* REGIONAL Applications */



#if defined REGIONAL
/*
!====================================================================
!               REGIONAL (realistic) Configurations
!====================================================================
!
!----------------------
! BASIC OPTIONS
!----------------------
!
*/
                      /* Configuration Name */
# define CAPSTONE

                      /* Parallelization */
# undef  OPENMP
# define  MPI
                      /* Non-hydrostatic option */
# undef  NBQ
# undef  CROCO_QH
                      /* Nesting */
# undef  AGRIF
# undef  AGRIF_2WAY
                      /* OA and OW Coupling via OASIS (MPI) */
# undef  OA_COUPLING
# undef  OW_COUPLING
# ifdef OW_COUPLING
#  undef OW_COUPLING_FULL
# endif
                      /* Wave-current interactions */
# undef  MRL_WCI
                      /* Open Boundary Conditions */
# undef  TIDES
# undef OBC_EAST
# undef OBC_WEST
# undef OBC_NORTH
# undef OBC_SOUTH
# define EW_PERIODIC
# undef NS_PERIODIC  /* We are making NS boundaries closed with free-slip*/
                      /* Applications */
# define  BIOLOGY
# undef  FLOATS
# undef  STATIONS
# undef  PASSIVE_TRACER
# undef  SEDIMENT
# undef  MUSTANG
# undef  BBL
                      /* I/O server */
# undef  XIOS
                      /* Calendar */
# undef  USE_CALENDAR  
                      /* dedicated croco.log file */
# undef  LOGFILE
/*    
!-------------------------------------------------
! PRE-SELECTED OPTIONS
!
! ADVANCED OPTIONS ARE IN CPPDEFS_DEV.H
!-------------------------------------------------
*/
                      /* Parallelization */
# ifdef MPI
#  undef  PARALLEL_FILES
#  undef  NC4PAR
#  undef  MPI_NOLAND
#  undef  MPI_TIME
# endif
# undef  AUTOTILING
                      /* Non-hydrostatic options */
# ifdef NBQ
#  define W_HADV_TVD
#  define W_VADV_TVD
# endif
                      /* Grid configuration */
# define CURVGRID
# define SPHERICAL
# define MASKING
# undef  WET_DRY
# define NEW_S_COORD
                      /* Model dynamics */
# define SOLVE3D
# define UV_COR
# define UV_ADV
                      /* Equation of State */
# define SALINITY
# define NONLIN_EOS
                      /* Surface Forcing */
/*
! Bulk flux algorithms (options)
! by default : COARE3p0 paramet with GUSTINESS effects
!
! To change bulk param, define one the following keys (exclusive) :
! - define BULK_ECUMEV0 : ECUME_v0 param
! - define BULK_ECUMEV6 : ECUME_v6 param
! - define BULK_WASP    : WASP param
! Note : gustiness effects can be added for all params
!        by defining BULK_GUSTINESS
*/
# undef BULK_FLUX
# ifdef BULK_FLUX
#  undef  BULK_ECUMEV0
#  undef  BULK_ECUMEV6
#  undef  BULK_WASP
#  define BULK_GUSTINESS
#  define BULK_LW
#  undef  SST_SKIN
#  undef  ANA_DIURNAL_SW
#  undef  ONLINE
#  ifdef ONLINE
#   undef  AROME
#   undef  ERA_ECMWF
#  endif
#  undef  READ_PATM
#  ifdef READ_PATM
#   define OBC_PATM
#  endif
# else
#  define QCORRECTION
#  define SFLX_CORR
#  undef  SFLX_CORR_COEF
#  define ANA_DIURNAL_SW
# endif
# undef  SFLUX_CFB
# undef  SEA_ICE_NOFLUX
                      /* Lateral Forcing */
# undef CLIMATOLOGY
# undef  FRC_BRY

                      /* Lateral Momentum Advection (default UP3) */
# undef UV_HADV_UP3
# undef  UV_HADV_UP5
# define  UV_HADV_WENO5
# undef  UV_HADV_TVD
                      /* Lateral Explicit Momentum Mixing */
# undef  UV_VIS2

                      /* Vertical Momentum Advection */
# undef UV_VADV_SPLINES
# define  UV_VADV_WENO5
# undef  UV_VADV_TVD
                      /* Lateral Tracer Advection (default UP3) */
# undef  TS_HADV_UP3
# undef TS_HADV_RSUP3
# undef  TS_HADV_UP5
# define  TS_HADV_WENO5
                      /* Lateral Explicit Tracer Mixing */
# define  TS_DIF2
# undef  TS_DIF4
# undef  TS_MIX_S
                      /* Vertical Tracer Advection  */
# undef TS_VADV_SPLINES
# undef  TS_VADV_AKIMA
# define  TS_VADV_WENO5
                      /* Sponge layers for UV and TS */
# undef SPONGE
                      /* Semi-implicit Vertical Tracer/Mom Advection */
# undef  VADV_ADAPT_IMP
                      /* Bottom friction in fast 3D step */
# define LIMIT_BSTRESS
# undef  BSTRESS_FAST
                      /* Vertical Mixing */
# undef  BODYFORCE
# undef  BVF_MIXING
# undef LMD_MIXING
# define  GLS_MIXING


                      /* Bottom Forcing */
# define ANA_BSFLUX
# define ANA_BTFLUX
                      /* Point Sources - Rivers */
# undef PSOURCE
# undef PSOURCE_NCFILE
# ifdef PSOURCE_NCFILE
#  undef PSOURCE_NCFILE_TS
# endif
                      /* Open Boundary Conditions */

# define OBC_M2CHARACT
# undef  OBC_M2ORLANSKI
# define OBC_M3ORLANSKI
# define OBC_TORLANSKI
# undef  OBC_M2SPECIFIED
# undef  OBC_M3SPECIFIED
# undef  OBC_TSPECIFIED
                      /* Input/Output */
# define AVERAGES
# define AVERAGES_K
# undef  OUTPUTS_SURFACE
# undef  HOURLY_VELOCITIES
                     /* Exact restart */
# undef EXACT_RESTART
                      /* Parallel reproducibility or restartabilty test */
# undef RVTK_DEBUG
# undef RVTK_DEBUG_PERFRST
# if defined RVTK_DEBUG && !defined RVTK_DEBUG_PERFRST
!    Parallel reproducibility test
#  undef RVTK_DEBUG_ADVANCED
#  define XXXRVTK_DEBUG_READ
# elif defined RVTK_DEBUG && defined RVTK_DEBUG_PERFRST
!    Restartability test
#  define EXACT_RESTART
#  undef RVTK_DEBUG_ADVANCED
#  define XXXRVTK_DEBUG_READ
# endif
!    RVTK test (Restartability or Parallel reproducibility)                
# if defined RVTK_DEBUG && defined BULK_FLUX && defined ONLINE
#  define BULK_MONTH_1DIGIT
# endif
/*
!                        Diagnostics
!--------------------------------------------
! 3D Tracer & momentum balance
! 2D Mixing layer balance
! Depth-mean vorticity and energy balance
! Eddy terms
!--------------------------------------------
!
*/
# undef DO_NOT_OVERWRITE
# undef RESTART_DIAGS

# undef DIAGNOSTICS_TS
# undef DIAGNOSTICS_UV
# ifdef DIAGNOSTICS_TS
#  undef  DIAGNOSTICS_TS_ADV
#  undef  DIAGNOSTICS_TS_MLD
# endif

# undef DIAGNOSTICS_TSVAR
# ifdef DIAGNOSTICS_TSVAR
#  define  DIAGNOSTICS_TS
#  define  DIAGNOSTICS_TS_ADV
# endif

# undef  DIAGNOSTICS_VRT
# undef  DIAGNOSTICS_EK
# ifdef DIAGNOSTICS_EK
#  undef DIAGNOSTICS_EK_FULL
#  undef DIAGNOSTICS_EK_MLD
# endif

# undef DIAGNOSTICS_BARO
# undef DIAGNOSTICS_PV
# undef DIAGNOSTICS_DISS
# ifdef DIAGNOSTICS_DISS
#  define DIAGNOSTICS_PV
# endif

# undef DIAGNOSTICS_EDDY

# undef TENDENCY
# ifdef TENDENCY
#  define DIAGNOSTICS_UV
# endif
/*
!           Applications:
!---------------------------------
! Biology, floats, Stations,
! Passive tracer, Sediments, BBL
!---------------------------------
!
   Quasi-monotone lateral advection scheme (WENO5)
   for passive/biology/sediment tracers
*/
# if defined PASSIVE_TRACER || defined BIOLOGY || defined SEDIMENT \
                                               || defined MUSTANG
#  define BIO_HADV_WENO5
# endif
                      /*   Choice of Biology models   */
# ifdef BIOLOGY
#  undef  PISCES
#  define  BIO_NChlPZD
#  undef  BIO_N2ChlPZD2
#  undef BIO_BioEBUS
                      /*   Biology options    */

#  ifdef BIO_NChlPZD
#   define  OXYGEN
#  endif

                      /*   Biology diagnostics    */
#  define DIAGNOSTICS_BIO
#  if defined DIAGNOSTICS_BIO && defined PISCES
#   define key_trc_diaadd
#  endif
# endif
                      /*   Lagrangian floats model    */

                      /*   Stations recording    */
# ifdef STATIONS
#  define ALL_SIGMA
# endif
                      /*   USGS Sediment model     */
# ifdef SEDIMENT
#  define SUSPLOAD
#  define BEDLOAD
#  define MORPHODYN
# endif
                      /*   MUSTANG Sediment model     */
# ifdef MUSTANG
#  undef  key_MUSTANG_V2
#  undef  key_MUSTANG_bedload
#  undef  MORPHODYN
#  define key_sand2D
#  define MUSTANG_CORFLUX
#  undef  key_tauskin_c_upwind
#  undef  WAVE_OFFLINE
# endif


#endif /* END OF CONFIGURATION CHOICE */

#include "cppdefs_dev.h"
#include "set_global_definitions.h"
