import numpy as np

def split_legs_by_x(leg_points):
    """
    leg_points: (N,2) numpy array (x,y) in pixels
    returns dict of 4 leg clusters
    """

    if len(leg_points) < 20:
        return {}

    # sort by x
    pts = leg_points[np.argsort(leg_points[:, 0])]

    n = len(pts)
    step = n // 4

    return {
        "left_back":  pts[0:step],
        "left_front": pts[step:2*step],
        "right_front": pts[2*step:3*step],
        "right_back":  pts[3*step:]
    }