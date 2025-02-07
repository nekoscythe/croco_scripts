import numpy as np
import xarray
import xroms

import sys
sys.path.append('/home/mk7641/storage/Utils/')
from Utils_2 import *
import os

def uvp_mask(rfield):
    # Get dimensions of rfield
    Mp, Lp = rfield.shape

    # Compute reduced dimensions
    M = Mp - 1
    L = Lp - 1

    # Compute vfield
    vfield = rfield[0:M, :] * rfield[1:Mp, :]

    # Compute ufield
    ufield = rfield[:, 0:L] * rfield[:, 1:Lp]

    # Compute pfield
    pfield = ufield[0:M, :] * ufield[1:Mp, :]

    return ufield, vfield, pfield

def spheric_dist(lat1, lat2, lon1, lon2):
    # Earth radius (in meters) as a double-precision value
    R = 6367442.76
    
    # Convert degrees to radians, ensuring double precision
    lat1 = np.radians(lat1)
    lat2 = np.radians(lat2)
    lon1 = np.radians(lon1)
    lon2 = np.radians(lon2)
    
    # Compute the longitudinal difference and adjust for values >= 180 degrees
    l = np.abs(lon2 - lon1)
    l = np.where(l >= np.pi, 2 * np.pi - l, l)  # Cast result to double precision
    
    # Compute the chord-based formula with double precision
    dist = R * np.arcsin(
        np.sqrt(
            (np.sin(l) * np.cos(lat2))**2
            + (np.sin(lat2) * np.cos(lat1) - np.sin(lat1) * np.cos(lat2) * np.cos(l))**2
        )
    )
    
    return dist


def get_angle(latu, lonu):
    A = 6378137.0  # WGS 1984 semi-major axis in meters
    E = 0.081819191  # Eccentricity of the Earth
    B = np.sqrt(A**2 - (A * E)**2)  # Semi-minor axis
    
    EPS = (E**2 / (1 - E**2))

    # Convert latitude and longitude to radians (ensure double precision)
    latu = np.radians(latu)
    lonu = np.radians(lonu)

    # Fix numerical issues for 0/0 cases
    latu[latu == 0] = np.finfo(np.float64).eps


    # Endpoints of each segment
    PHI1 = latu[:, :-1]  # Latitude at point 1
    XLAM1 = lonu[:, :-1]  # Longitude at point 1
    PHI2 = latu[:, 1:]   # Latitude at point 2
    XLAM2 = lonu[:, 1:]   # Longitude at point 2

    # Wiggle lines of constant lat/lon to prevent numerical issues
    PHI2[PHI1 == PHI2] += 1e-14
    XLAM2[XLAM1 == XLAM2] += 1e-14

    # Compute the radius of curvature in the prime vertical for each point
    xnu1 = A / np.sqrt(1 - (E * np.sin(PHI1))**2)
    xnu2 = A / np.sqrt(1 - (E * np.sin(PHI2))**2)

    # Compute the azimuths
    TPSI2 = (1 - E**2) * np.tan(PHI2) + E**2 * xnu1 * np.sin(PHI1) / (xnu2 * np.cos(PHI2))

    # Compute angle difference
    DLAM = XLAM2 - XLAM1
    CTA12 = (np.cos(PHI1) * TPSI2 - np.sin(PHI1) * np.cos(DLAM)) / np.sin(DLAM)
    azim = np.arctan(1 / CTA12)

    # Adjust the quadrant
    DLAM2 = np.where(
        np.abs(DLAM) < np.pi, DLAM,
        np.where(DLAM >= np.pi, -2 * np.pi + DLAM, 2 * np.pi + DLAM)
    )
    azim = np.where(azim < -np.pi, azim + 2 * np.pi, azim)
    azim = np.where(azim >= np.pi, azim - 2 * np.pi, azim)
    azim = azim + np.pi * np.sign(-azim) * (np.sign(azim) != np.sign(DLAM2))

    # Compute the angle
    angle = np.zeros((latu.shape[0], latu.shape[1] + 1), dtype=np.float64)  # Add an extra column
    angle[:, 1:-1] = (np.pi / 2) - azim
    angle[:, 0] = angle[:, 1]
    angle[:, -1] = angle[:, -2]  # Copy the second-to-last column into the last

    return angle

def get_metrics(latu, lonu, latv, lonv):
    """
    Compute the grid metrics (pm, pn, dndx, dmde) from latitude and longitude arrays.
    """
    # Get grid dimensions
    Mp, L = latu.shape
    M, Lp = latv.shape
    Lm = L - 1
    Mm = M - 1

    # Initialize arrays
    dx = np.zeros((Mp, Lp))
    dy = np.zeros((Mp, Lp))

    # Compute dx (distance between u-points)
    dx[:, 1:L] = spheric_dist(latu[:, :Lm], latu[:, 1:L], lonu[:, :Lm], lonu[:, 1:L])
    dx[:, 0] = dx[:, 1]  # Fill boundaries
    dx[:, Lp - 1] = dx[:, Lm]  # Fill boundaries

    # Compute dy (distance between v-points)
    dy[1:M, :] = spheric_dist(latv[:Mm, :], latv[1:M, :], lonv[:Mm, :], lonv[1:M, :])
    dy[0, :] = dy[1, :]  # Fill boundaries
    dy[Mp - 1, :] = dy[Mm, :]  # Fill boundaries

    # Compute pm and pn (inverse of dx and dy)
    pm = 1.0 / dx
    pn = 1.0 / dy

    # Compute dndx and dmde (gradients of pn and pm)
    dndx = np.zeros((Mp, Lp))
    dmde = np.zeros((Mp, Lp))

    dndx[1:M, 1:L] = 0.5 * (1.0 / pn[1:M, 2:Lp] - 1.0 / pn[1:M, :Lm])
    dmde[1:M, 1:L] = 0.5 * (1.0 / pm[2:Mp, 1:L] - 1.0 / pm[:Mm, 1:L])

    # Set boundaries to zero
    dndx[0, :] = 0
    dndx[Mp - 1, :] = 0
    dndx[:, 0] = 0
    dndx[:, Lp - 1] = 0

    dmde[0, :] = 0
    dmde[Mp - 1, :] = 0
    dmde[:, 0] = 0
    dmde[:, Lp - 1] = 0

    return pm, pn, dndx, dmde



def rho2uvp(grid):
    """Convert rho points to u, v, and psi points."""
    u = 0.5 * (grid[:, 1:] + grid[:, :-1])  # Average in the xi-direction (columns)
    v = 0.5 * (grid[1:, :] + grid[:-1, :])  # Average in the eta-direction (rows)
    p = 0.5 * (u[1:, :] + u[:-1, :])  # Average of u in the eta-direction (rows)
    return u, v, p



def create_grid(source_data, missing_value, CROCO_title="test_grid"):
    """
    Create a CROCO grid using xarray and save it to a NetCDF file.
    """
    
    latmin = source_data['lat_rho'].min()
    latmax = source_data['lat_rho'].max()
    lonmin = source_data['lon_rho'].min()
    lonmax = source_data['lon_rho'].max()
    
    #grid resolution
    dl = (source_data['lon_rho'][0, 1] - source_data['lon_rho'][0, 0]).values
    
    lonr = np.arange(lonmin, lonmax, dl)
    
    latr = [latmin]  # Start with a double-precision latmin
    print(latr)
    i = 0
    while latr[i] <= latmax:  # Ensure latmax is treated as double
        i += 1
        next_lat = latr[i-1] + dl * np.cos(np.radians(latr[i-1]))  # Use double-precision arithmetic
        latr.append(next_lat)

    print("done")
    # Convert the list to a numpy array if needed
    latr = np.array(latr, dtype=np.float64)
    
    
    #convert to meshgrid
    lonr, latr = np.meshgrid(lonr, latr)

    
    # Create staggered grids (u, v, psi points)
    Lonu, Lonv, Lonp = rho2uvp(lonr)
    Latu, Latv, Latp = rho2uvp(latr)
    
    M, L = Latp.shape
    print(' LLm = ', L-1)
    print(' MMm = ', M-1)
    print('Resolution = ', dl)
    

    # Compute metrics
    pm, pn, dndx, dmde = get_metrics(Latu, Lonu, Latv, Lonv)

    # Compute x and y coordinates
    xr = np.zeros_like(lonr)
    yr = np.zeros_like(latr)
    for i in range(lonr.shape[1] - 1):
        xr[:, i + 1] = xr[:, i] + 2.0 / (pm[:, i + 1] + pm[:, i])
    for j in range(latr.shape[0] - 1):
        yr[j + 1, :] = yr[j, :] + 2.0 / (pn[j + 1, :] + pn[j, :])
    xu, xv, xp = rho2uvp(xr)
    yu, yv, yp = rho2uvp(yr)

    # Compute angle
    angle = get_angle(Latu, Lonu)

    # Compute Coriolis parameter
    f = 4 * np.pi * np.sin(np.deg2rad(latr)) * 366.25 / (24 * 3600 * 365.25)

    # Compute bathymetry (replace with actual data)
    h = np.ones_like(lonr) * 2000 #2000 m constant depth
    hraw = np.ones((1, lonr.shape[0], lonr.shape[1])) * missing_value
    alpha = np.ones_like(lonr) * missing_value

    # Compute masks
    maskr = h > 0
    masku, maskv, maskp = uvp_mask(maskr)

    spherical = np.array([b'T'], dtype='|S1')[0]

    # # Create xarray Dataset
    ds = xarray.Dataset(
        {
            "xl": (["one"], [missing_value]),
            "el": (["one"], [missing_value]),
            "depthmin": (["one"], [missing_value]),
            "depthmax": (["one"], [missing_value]),
            "spherical": (["one"], [spherical]),
            "angle": (["eta_rho", "xi_rho"], angle),
            "h": (["eta_rho", "xi_rho"], h),
            "hraw": (["bath", "eta_rho", "xi_rho"], hraw),
            "alpha": (["eta_rho", "xi_rho"], alpha),
            "f": (["eta_rho", "xi_rho"], f),
            "pm": (["eta_rho", "xi_rho"], pm),
            "pn": (["eta_rho", "xi_rho"], pn),
            "dndx": (["eta_rho", "xi_rho"], dndx),
            "dmde": (["eta_rho", "xi_rho"], dmde),
            "x_rho": (["eta_rho", "xi_rho"], xr),
            "x_u": (["eta_u", "xi_u"], xu),
            "x_v": (["eta_v", "xi_v"], xv),
            "x_psi": (["eta_psi", "xi_psi"], xp),
            "y_rho": (["eta_rho", "xi_rho"], yr),
            "y_u": (["eta_u", "xi_u"], yu),
            "y_v": (["eta_v", "xi_v"], yv),
            "y_psi": (["eta_psi", "xi_psi"], yp),
            "lon_rho": (["eta_rho", "xi_rho"], lonr),
            "lat_rho": (["eta_rho", "xi_rho"], latr),
            "lon_u": (["eta_u", "xi_u"], Lonu),
            "lat_u": (["eta_u", "xi_u"], Latu),
            "lon_v": (["eta_v", "xi_v"], Lonv),
            "lat_v": (["eta_v", "xi_v"], Latv),
            "lon_psi": (["eta_psi", "xi_psi"], Lonp),
            "lat_psi": (["eta_psi", "xi_psi"], Latp),
            "mask_rho": (["eta_rho", "xi_rho"], maskr),
            "mask_u": (["eta_u", "xi_u"], masku),
            "mask_v": (["eta_v", "xi_v"], maskv),
            "mask_psi": (["eta_psi", "xi_psi"], maskp),
        },
        attrs={"title": CROCO_title, "resolution": f"1/{1/dl} deg", "type": "CROCO grid file"},
    )

    return ds

def __main__():
    #find the *_rst.nc file
    current_dir = os.getcwd()
    #see if any file ends with _rst.nc
    path = None
    for file in os.listdir(current_dir):
        if file.endswith("_rst.nc"):
            path = file
            break
    
    if path == None:
        print("No file found")
        return
    
    
    #load the data
    data = xarray.open_dataset(path)
    #missing value
    missing_value = data['xl'].values
    
    #ask for the resolution configuration
    print("Enter the resolution configuration")
    print("1. High")
    print("2. Medium")
    print("3. Low")
    res = int(input())
    
    if res == 1:
        latmin = 45
        latmax = 50
        lonmin = -175
        lonmax = -60
        dl = 0.012524
    elif res == 2:
        latmin = 45
        latmax = 50
        lonmin = -70
        lonmax = -60
        dl = 0.025048
        
    
    #generate the grid
    grid = create_grid(data, missing_value)
    grid_name = path.split('_rst.nc')[0] + '_grd.nc'
    grid.to_netcdf(grid_name)

if __name__ == "__main__":
    __main__()