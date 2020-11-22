#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Nov  7 23:21:41 2020

@author: my-python
"""


import ode
import pandas as pd

# Collision callback
def near_callback(args, geom1, geom2):
    """Callback function for the collide() method.
    This function checks if the given geoms do collide and
    creates contact joints if they do.
    """

    # Check if the objects do collide
    contacts = ode.collide(geom1, geom2)

    # Create contact joints
    world, contactgroup = args
    for c in contacts:
        c.setBounce(1.0) # 反発係数
        c.setMu(5000)  # クーロン摩擦係数
        j = ode.ContactJoint(world, contactgroup, c)
        j.attach(geom1.getBody(), geom2.getBody())

contactgroup = ode.JointGroup()
# Create a world object
# https://so-zou.jp/robot/tech/physics-engine/ode/object/world.htm
world = ode.World()

world.setGravity((0,-9.81,0))
# ERPとはシミュレーションのステップごとに発生する計算誤差を減少させるためのパラメータです。
# world.setERP(0.2)
# CFMとは拘束の強さを決定するパラメータです。
# world.setCFM(1E-5)

# Create a space object
# http://ode.org/wiki/index.php?title=Manual#Space_functions
space = ode.Space()

# Create a plane geom which prevent the objects from falling forever
# http://ode.org/wiki/index.php?title=Manual#Plane_Class
floor_y = ode.GeomPlane(space, (0,1,0), 0)
floor_y2= ode.GeomPlane(space, (0,1,0), -1)
floor_x_t = ode.GeomPlane(space, (-1,0,0), -1)
floor_x_b = ode.GeomPlane(space, (1,0,0), -1)
floor_z_t = ode.GeomPlane(space, (0,0,-1), -1)
floor_z_b = ode.GeomPlane(space, (0,0,1), -1)

# Create a body inside the world
radius = 0.2

body = ode.Body(world)
M = ode.Mass()
M.setSphere(250.0, radius)

body.setMass(M)
body.setPosition( (0,2,0) )

Ball_Geom = ode.GeomSphere(space, radius=radius)
Ball_Geom.setBody(body)

# Do the simulation...
total_time = 0.0
dt = 0.04
list_results = []
while total_time<10.0:
    # Detect collisions and create contact joints
    space.collide((world,contactgroup), near_callback)

    x,y,z = body.getPosition()
    u,v,w = body.getLinearVel()
    print("{:,.2f}fsec: pos=({:,.3f}, {:,.3f}, {:,.3f})  vel=({:,.3f}, {:,.3f}, {:,.3f})".format(total_time, x, y, z, u,v,w))
    world.step(dt)
    total_time+=dt
    
    list_results.append([total_time, x, y, z, u,v,w])
    
    if total_time > 7:
        floor_y.enable()
    elif total_time > 3:
        floor_y.disable()
    else:
        floor_y.enable()
    
    
    contactgroup.empty()
    
df_results = pd.DataFrame(list_results, columns=["total_time", "x", "y", "z", "u" ,"v" ,"w"]).set_index("total_time")
df_results.plot(subplots=True)