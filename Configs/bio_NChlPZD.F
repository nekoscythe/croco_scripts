! $Id: bio_NChlPZD.F 1458 2014-02-03 15:01:25Z gcambon $
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
#include "cppdefs.h"
#if defined BIOLOGY && defined BIO_NChlPZD

      subroutine biology_tile (Istr,Iend,Jstr,Jend)
!
! Compute biological forcing functions
!
! In this particular implementation there is 2 compartments:
! NO3, PHYTOplankton.
!
      implicit none
      integer Istr,Iend,Jstr,Jend
#include "param.h"
#include "grid.h"
#include "ocean3d.h"
#include "ocean2d.h"
#include "diagnostics.h"
#include "scalars.h"
#include "forces.h"
#include "mixing.h"

      real kwater, palpha, kChla, CN_Phyt, theta_m, opc,
     &     K_NO3, mu_P_D
      integer ITERMAX
#ifdef DIAGNOSTICS_BIO

      real trend_no3,trend_phy,somme
      real bilan_no3,bilan_phy, 
     &     trend_total
      integer l, iflux
      real ThisFlux(N, NumFluxTerms)
#endif
      parameter (
     &  ITERMAX = 3,      ! number of small implicit time step
!
! Parameters as in Table 1; Fasham et al. [JMR, 48, 591-639, 1990]
!
     &  kwater  = 0.04,    ! light attenuation due to sea water  [m-1]
                           ! range:(0.04<==>0.04];    units:[m-1]
     &  palpha  = 1.0,     ! initial slope of the P-I curve
                           ! range:(1.00<==>1.00);       [(W m-2 d)-1]
     &  kChla  = 0.024,    ! light attenuation by Chlorophyl  
                           !                         [(m^2 mg Chla)-1]
     &  CN_Phyt= 6.625,    ! C:N ratio for phytoplankton
                           !                       [mMol C (mMol N)-1]
     &  theta_m= 0.0535,    ! max Cellular Chlorophyll to Carbon Ratio
                           ! range:(0.015<==>0.072);    [mg Chla/mg C]
     &  K_NO3   = 1./10,  ! inverse half-saturation for Phytoplankton
                           ! range:(1./.0 <==> 1./.9);[1/(mmol-N m-3)]
     &  mu_P_D  = 0.03)   ! Phyto mortality to Det rate        [d-1]) 
!
      integer i,j,k, ITER, iB
      real    NO3(N), Phyt(N), Chla(N),
     &        aJ(N),FC(0:N),
     &        PAR, PARsup, attn, Vp, Epp, cu, aL,aR, dtdays, L_NO3,
     &        E_NO3,cff,cff0,cff1
     
# if defined OXYGEN || defined DIAGNOSTICS_BIO
     &      , dtsec     ! length of time step in seconds (for gas exchange)
# endif
!
# include "compute_auxiliary_bounds.h"
!
      dtdays=dt/(24.*3600.*float(ITERMAX))  ! time step as fraction of day.
# if defined DIAGNOSTICS_BIO || defined OXYGEN
      dtsec = dt / float(ITERMAX)           ! time step in seconds
# endif /* DIAGNOSTICS_BIO || OXYGEN */
!
!
! Since the following solver is iterative to achieve implicit
! discretization of the biological interaction, two time slices are
! required, BIO where BIO is understood as vector of
! biological state variables: BIO=[NO3,Phyt,Zoo,Det]. Assume
! that the iterations converge, the newly obtained state variables
! satisfy equations
!
!           BIO = BIO + dtdays * rhs(BIO)
! 
! where rhs(BIO) is the vector of biological r.h.s. computed at
! the new time step. During the iterative procedure a series of
! fractional time steps is performed in a chained mode (splitting
! by different biological conversion processes) in sequence NO3 -- 
! Phyt -- Zoo -- Det, that is the main food chain. In all 
! stages the concentration of the component being consumed is
! treated in fully implicit manner, so that the algorithm guarantees
! non-negative values, no matter how strong is the concentration of
! active consuming component (Phyto or Zoo).
!
! The overall algorithm, as well as any stage of it is formulated
! in conservative form in sense that the
! sum of concentration of all five components is conserved.
!

/*
#  ifdef EW_PERIODIC
#   define I_RANGE Istr,Iend
#  else
#   define I_RANGE IstrR,IendR
#  endif
#  ifdef NS_PERIODIC
#   define J_RANGE Jstr,Jend
#  else
#   define J_RANGE JstrR,JendR
#  endif
*/
#  define I_RANGE Istr,Iend
#  define J_RANGE Jstr,Jend



      do j=J_RANGE
        do i=I_RANGE
#ifdef DIAGNOSTICS_BIO
! Reset the biogeochemical fluxes. This is necessary because the
! biological routine uses multiple. time steps for each physical time
! step.
          do k=1,N
            do l=1,NumFluxTerms
              bioFlux(i,j,k,l) = 0.0
            enddo
          end do


#endif /* DIAGNOSTICS_BIO */
!
! Extract biological variables from tracer arrays; place them into
! scratch variables; restrict their values to be positive definite.
!

      do k=1,N
        NO3(k) =max(t(i,j,k,nnew,iNO3_)  ,0.)   ! Nitrate
        Phyt(k)=max(t(i,j,k,nnew,iPhy1)  ,0.)   ! Phytoplankton
        Chla(k)=max(t(i,j,k,nnew,iChla)  ,0.)   ! Chlor a
      enddo



      DO ITER=1,ITERMAX      !--> Start internal iterations to achieve
                             !    nonlinear backward-implicit solution.

        PAR=srflx(i,j)*rho0*Cp*0.43
        opc=0.01*PAR

        if (PAR.gt.0.) then
!
!   *** SUN IS UP ***
!
! Calulate aJ: Set Photosynthetically Available Radiation (PAR) at
! surface from solar radiation x 0.43. Then, within each grid box
! compute attenuation coefficient based on the concentration of
! Phytoplankton inside the grid box, and attenuate PAR from surface
! down (thus, PAR at certain depth depends on the whole distribution
! of Phytoplankton above). To compute aJ, one needs PAR somewhat in
! the middle of the gridbox, so that attenuation "attn" corresponds
! to half of the grid box height, while PAR is multiplied by it
! twice: once to get it in the middle of grid-box and once the
! compute on trhe lower grid-box interface;
! 
          do k=N,1,-1     !<-- irreversible

            attn=exp(-0.5*(kwater+kChla*Chla(k))*
     &               (z_w(i,j,k)-z_w(i,j,k-1)))

            PARsup=PAR*attn
            Vp=0.59*(1.066**t(i,j,k,nnew,itemp))   ! From Eppley
!            Vp=0.8356*(1.066**t(i,j,k,nnew,itemp))   ! a.b^cT=µ_max=3.0
            cff0=PARsup*palpha*theta_m           ! for diatoms & 
            Epp=Vp/sqrt(Vp*Vp+cff0*cff0)             ! 2.0 for flagelates
            aJ(k)=Epp*cff0

! (1) NO3 uptake by Phyto
!
            E_NO3=K_NO3/(1+K_NO3*NO3(k)) ! Parker 1993 Ecol Mod. 66 113-120
            cff=dtdays*aJ(k)*Phyt(k)*E_NO3
            ! print*, "CFF: ", cff
            NO3(k)=NO3(k)/(1.+cff)
            
            ! Growth step
            Phyt(k)=Phyt(k)+cff*NO3(k)

#ifdef DIAGNOSTICS_BIO
            ThisFlux(k, NFlux_NewProd) = cff*NO3(k)
#endif /* DIAGNOSTICS_BIO */


            PAR=PARsup*attn
!      Calcul of the euphotic depth
!
            if (PARsup.ge.opc) then
              if (PAR.ge.opc) then
                hel(i,j)=-z_w(i,j,k-1)
              else
                hel(i,j)=-z_r(i,j,k)
              endif
            endif
!
          enddo
!
        else
#ifdef DIAGNOSTICS_BIO
          do k = N, 1, -1
            ThisFlux(k, NFlux_NewProd) = 0.0 
          enddo
#endif /* DIAGNOSTICS_BIO */
!#ifdef AVERAGES
!! if the sun is down, set the logical variable "sun_down"
!! to true for not taking into account this time step in the averaging
!          if ((ZEROTH_TILE).and.(srflx(Istr,Jstr).eq.0.)) then
!            sun_down=.true.
!          endif
!#endif

          hel(i,j)=0.0
        endif
!
! (1) Phytoplankton mortality to Detr (mu_P_D)
!
        cff1=dtdays*mu_P_D
        do k=1,N
          Phyt(k)=Phyt(k)/(1. + cff1)
#ifdef DIAGNOSTICS_BIO
          ThisFlux(k, NFlux_Pmort) = Phyt(k) * cff1
#endif /* DIAGNOSTICS_BIO */
        enddo

!
#ifdef DIAGNOSTICS_BIO
! Transfer fluxes to global arrays at the end of each biological time step
! for computational efficiency, divide now by dtsec to get the correct units
        do iflux = 1, NumFluxTerms
          do k = 1, N
            bioFlux(i,j,k,iflux) = ( bioFlux(i,j,k,iflux) +
     &                               ThisFlux(k, iflux) / dt )
# ifdef MASKING
     &             * rmask(i,j)
# endif /* MASKING */
          end do
        end do


#endif /* DIAGNOSTICS_BIO */
!
      ENDDO  ! <-- ITER
!
! Write back
!
!          print*,'N=',N
#undef DEBUG_BIO
# if defined DIAGNOSTICS_BIO && defined DEBUG_BIO
!
      k=N
      if ((i.eq.13).and.(j.eq.15)) then
        bilan_no3 = - bioFlux(i,j,k,NFlux_NewProd)
!
        bilan_phy = bioFlux(i,j,k,NFlux_NewProd)
     &           - bioFlux(i,j,k,NFlux_Pmort)

        somme = bilan_no3+bilan_phy
        trend_no3 = ( (min(t(i,j,k,nnew,iNO3_),0.) +NO3(k))
     &               - t(i,j,k,nnew,iNO3_) ) / dt
        trend_phy = ( (min(t(i,j,k,nnew,iPhy1),0.) +Phyt(k))
     &               - t(i,j,k,nnew,iPhy1) )/ dt
        trend_total =  trend_no3 + trend_phy
!
! 
        print*, '=================='
        print*, 'i=',i,' j=',j,' k=',k
        print*, 'somme SMS(of N)=         ',somme
        print*, 'trend_total of N=        ',trend_total
        print*, 'These three values have to be the same!'
        print*, 'Error for N = trend_total-somme=',trend_total-somme
        print*, "-----------------"
        print*, 'bilan_no3 - trend_no3=', bilan_no3-trend_no3
        print*, 'bilan_phy-trend_phy=  ', bilan_phy-trend_phy
        print*, 'bilan_zoo-trend_zoo=  ', bilan_zoo-trend_zoo
        print*, 'bilan_det-trend_det=  ', bilan_det-trend_det
        print*, '-----------------'
        print*, 'bioFlux(i,j,k,NFlux_NewProd)= ', 
     &                               bioFlux(i,j,k,NFlux_NewProd)
        print*, 'bioFlux(i,j,k,NFlux_Pmort)=   ', 
     &                               bioFlux(i,j,k,NFlux_Pmort)
        print*, '=================='
      endif
# endif

          do k=1,N
            t(i,j,k,nnew,iNO3_)=min(t(i,j,k,nnew,iNO3_),0.) +NO3(k)
            t(i,j,k,nnew,iPhy1)=min(t(i,j,k,nnew,iPhy1),0.) +Phyt(k)
            t(i,j,k,nnew,iChla)=min(t(i,j,k,nnew,iChla),0.) +
     &                              CN_Phyt*12.*Phyt(k)*theta_m
          enddo
        enddo
      enddo


#else
      subroutine biology_empty ()
#endif
      return
      end
  