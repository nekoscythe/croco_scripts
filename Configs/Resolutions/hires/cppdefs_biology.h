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
/* 
        SELECT ACADEMIC TEST CASES 
*/
#undef  BASIN           /* Basin Example */
#undef  CANYON          /* Canyon Example */
#undef  EQUATOR         /* Equator Example  */
#undef  INNERSHELF      /* Inner Shelf Example */
#undef  SINGLE_COLUMN   /* 1DV vertical mixing Example */
#undef  RIVER           /* River run-off Example */
#undef  OVERFLOW        /* Gravitational/Overflow Example */
#undef  SEAMOUNT        /* Seamount Example */
#undef  SHELFRONT       /* Shelf Front Example */
#undef  SOLITON         /* Equatorial Rossby Wave Example */
#undef  THACKER         /* Thacker wetting-drying Example */
#undef  UPWELLING       /* Upwelling Example */
#undef  VORTEX          /* Baroclinic Vortex Example */
#undef  INTERNAL        /* Internal Tide Example */
#undef  IGW             /* COMODO Internal Tide Example */
#undef  JET             /* Baroclinic Jet Example */
#undef  SHOREFACE       /* Shoreface Test Case on a Planar Beach */
#undef  RIP             /* Rip Current Test Case */
#undef  SANDBAR         /* Bar-generating Flume Example */
#undef  SWASH           /* Swash Test Case on a Planar Beach */
#undef  TANK            /* Tank Example */
#undef  MOVING_BATHY    /* Moving Bathymetry Example */
#undef  ACOUSTIC        /* Acoustic wave Example */
#undef  GRAV_ADJ        /* Graviational Adjustment Example */
#undef  ISOLITON        /* Internal Soliton Example */
#undef  KH_INST         /* Kelvin-Helmholtz Instability Example */
#undef  TS_HADV_TEST    /* Horizontal tracer advection Example */
#undef  DUNE            /* Dune migration Example */
#undef  SED_TOY         /* 1DV sediment toy Example */
#undef  TIDAL_FLAT      /* 2DV tidal flat Example */
#undef  ESTUARY         /* 3D tidal estuary Example */
/* 
        ... OR REALISTIC CONFIGURATIONS
*/
#undef  COASTAL         /* COASTAL Applications */
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
#  define  NC4PAR
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
# ifdef CLIMATOLOGY
#  define ZCLIMATOLOGY
#  define M2CLIMATOLOGY
#  define M3CLIMATOLOGY
#  define TCLIMATOLOGY

#  define ZNUDGING
#  define M2NUDGING
#  define M3NUDGING
#  define TNUDGING
#  undef  ROBUST_DIAG
# endif

# undef  FRC_BRY
# ifdef FRC_BRY
#  define Z_FRC_BRY
#  define M2_FRC_BRY
#  define M3_FRC_BRY
#  define T_FRC_BRY
# endif
                      /* Lateral Momentum Advection (default UP3) */
# undef UV_HADV_UP3
# undef  UV_HADV_UP5
# define  UV_HADV_WENO5
# undef  UV_HADV_TVD
                      /* Lateral Explicit Momentum Mixing */
# undef  UV_VIS2
# ifdef UV_VIS2
#  define UV_VIS_SMAGO
# endif
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
# ifdef LMD_MIXING
#  define LMD_SKPP
#  define LMD_BKPP
#  define LMD_RIMIX
#  define LMD_CONVEC
#  define LMD_NONLOCAL
#  undef  LMD_DDMIX
#  undef  LMD_LANGMUIR
# endif
                      /* Wave-current interactions */
# ifdef OW_COUPLING
#  define MRL_WCI
#  define BBL
# endif
# ifdef MRL_WCI
#  ifndef OW_COUPLING
#   undef  WAVE_OFFLINE
#   define ANA_WWAVE
#   undef  WKB_WWAVE
#  endif
#  undef  WAVE_ROLLER
#  define WAVE_STREAMING
#  define WAVE_FRICTION
#  define WAVE_RAMP
#  ifdef WKB_WWAVE
#   undef  WKB_OBC_NORTH
#   undef  WKB_OBC_SOUTH
#   define WKB_OBC_WEST
#   undef  WKB_OBC_EAST
#  endif
# endif
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
# ifdef TIDES
#  define SSH_TIDES
#  define UV_TIDES
#  define POT_TIDES
#  undef  TIDES_MAS
#  ifndef UV_TIDES
#   define OBC_REDUCED_PHYSICS
#  endif
#  define TIDERAMP
# endif
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
#  undef  BIO_NChlPZD
#  undef  BIO_N2ChlPZD2
#  define BIO_BioEBUS
                      /*   Biology options    */
#  ifdef PISCES
#   undef  DIURNAL_INPUT_SRFLX
#   define key_pisces
#   define key_ligand
#   undef key_pisces_quota
#   undef key_sediment
#  endif
#  ifdef BIO_NChlPZD
#   define  OXYGEN
#  endif
#  ifdef BIO_BioEBUS
#   define NITROUS_OXIDE
#  endif
                      /*   Biology diagnostics    */
#  define DIAGNOSTICS_BIO
#  if defined DIAGNOSTICS_BIO && defined PISCES
#   define key_trc_diaadd
#  endif
# endif
                      /*   Lagrangian floats model    */
# ifdef FLOATS
#  undef  FLOATS_GLOBAL_ATTRIBUTES
#  undef  IBM
#  undef  RANDOM_WALK
#  ifdef RANDOM_WALK
#   define DIEL_MIGRATION
#   define RANDOM_VERTICAL
#   define RANDOM_HORIZONTAL
#  endif
# endif
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
