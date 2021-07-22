/// @description Insert description here
// You can write your code in this editor
//***死亡
if(state==1)
{
	gravity=0.2;
	sprite_index=spr_haishi_dead;
	exit;
}
//***自动移动
x+=face*0.3;
if(x<0)x=room_width;
if(x>room_width)x=0;
//***脚下判断
if(collision_point(x-1,y+1,obj_wall_father,0,0))
{
	gravity=0;
	speed=0;
	y=collision_point(x-1,y+1,obj_wall_father,0,0).y-1;
	
}
if(!collision_point(x-2,y+1,obj_wall_father,0,0)&&!collision_point(x+2,y+1,obj_wall_father,0,0))
{
	
	gravity=0.2;
	sprite_index=spr_haishi_walk;
	image_index=2;
}

if(!collision_point(x-1,y+1,obj_wall_father,0,0)&&!collision_point(x+1,y+1,obj_wall_father,0,0))
{
	face=-face;
}


//***改变方向
image_xscale=face;