/// @description Insert description here
// You can write your code in this editor
/*触发移动视野*/
var yview;
yview=camera_get_view_y(ID);

if(obj_player.y<yview+240/3 
   && obj_player.jump==0 
   && timer==0) timer=32;
   
/*视野移动计算*/
if(timer)
{
	timer-=1;
	yview-=2;
	camera_set_view_pos(ID,0,yview);
	if(yview<0){
		yview=0;
		camera_set_view_pos(ID,0,yview);
		timer=0;
	}
}