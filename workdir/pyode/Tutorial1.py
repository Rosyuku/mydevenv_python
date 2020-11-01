#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 16:27:50 2020

@author: my-python

http://hooktail.sub.jp/mechanics/momentOfInertia/
http://pyode.sourceforge.net/tutorials/tutorial1.html
"""


# pyODE example 1: Getting started
    
import ode
import pandas as pd
# import matplotlib.pyplot as plt

# Create a world object
world = ode.World()
world.setGravity( (0,-9.81,0) )

# Create a body inside the world
body = ode.Body(world)
M = ode.Mass()
M.setSphere(2500.0, 0.05)
M.mass = 1.0
body.setMass(M)

body.setPosition( (0,2,0) )
body.addForce( (0,200,0) )

# Do the simulation...
total_time = 0.0
dt = 0.04
list_results = []
while total_time<2.0:
    x,y,z = body.getPosition()
    u,v,w = body.getLinearVel()
    print("{:,.2f}fsec: pos=({:,.3f}, {:,.3f}, {:,.3f})  vel=({:,.3f}, {:,.3f}, {:,.3f})".format(total_time, x, y, z, u,v,w))
    world.step(dt)
    total_time+=dt
    
    list_results.append([total_time, x, y, z, u,v,w])
    
df_results = pd.DataFrame(list_results, columns=["total_time", "x", "y", "z", "u" ,"v" ,"w"]).set_index("total_time")
df_results.plot(subplots=True)
