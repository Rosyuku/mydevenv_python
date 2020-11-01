#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov  1 23:00:17 2020

@author: my-python

https://algorithm.joho.info/programming/python/vpython-pyode-ball-free-fall/
"""


import vpython as vs
import ode

# 衝突判定の計算
def near_callback(args, geom1, geom2):
    e = 0.9 # 反発係数
    contacts = ode.collide(geom1, geom2)
    world, contactgroup = args
    for c in contacts:
        c.setBounce(e) # 反発係数の値をセット
        c.setMu(5000)  # 静止摩擦係数
        j = ode.ContactJoint(world, contactgroup, c)
        j.attach(geom1.getBody(), geom2.getBody())


def main():
    g = -9.81 # 重力加速度
    r = 0.5 # ボールの半径
    dt = 0.001 # 1フレームの時間
    t = 0.0    # 経過時間

    # ODEワールドの作成
    world = ode.World()
    world.setGravity((0, g, 0))

    # 剛体の作成
    ball_body = ode.Body(world) 
    m = ode.Mass()              
    m.setSphere(2500.0, 0.5)  
    ball_body.setMass(m)        
    ball_body.setPosition((0, 4, 0))

    # 衝突判定の設定
    space = ode.Space()
    floor_geom = ode.GeomPlane(space, (0, 1, 0), 0)
    ball_geom = ode.GeomSphere(space, radius=r)
    ball_geom.setBody(ball_body)
    contactgroup = ode.JointGroup()

    # フィールドの生成
    field = vs.box(size=vs.vector(4, 0.2, 4),
                   pos=vs.vector(0, 0, 0))
    
    # ボールの生成
    ball = vs.sphere(pos=vs.vector(0, 4, 0),
                     radius=r,
                     color=vs.vector(255,0,255))
    
    while t < 10.0:
        # 衝突判定
        space.collide((world, contactgroup), near_callback)

        # ODEの計算結果に応じてボールの位置を変化
        (x, y, z) =  ball_body.getPosition()
        ball.pos = vs.vector(x, y, z)
        vs.rate(1/dt)  #フレームレート
        world.step(dt) # 時間をdtだけ進める
        t += dt        # 経過時間の更新
        contactgroup.empty()

if __name__ == '__main__':
    main()