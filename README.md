

# 使用GameMakerStudio2制作《雪山兄弟》学习总结

>本篇为观看up主红色激情的教学视频所写的总结
>视频地址：[红激教你做游戏-GameMaker8游戏制作教程(新增番外篇)p4](https://www.bilibili.com/video/BV1Es41167QH?p=4)

### 导入资源

导入到GMS2，导入方式同《功夫》那篇相同。

###  新建房间，添加墙体、前景，激活视野,墙体的制作

创建room，载入背景图片
**在载入背景图片前需要新建一个新的背景图层，并设置为黑色，不然行走时会有残影留在屏幕中**
新建一个用来存墙体对象的group，新建一个父类对象obj_father，再创建七个继承这个父类的墙体对象，根据精灵创建。
在房间中绘制地图，并激活视野:

>相机属性Width256，Height240，**Ypos160**
>视口属性就宽高\*4即可Width1024，Height960
>*

### 创建玩家，设置基本属性

创建obj_player，精灵设置为spr_player_stand
添加创建事件

```GML
face=1;//方向1右	-1左
jump=0;//跳跃0	1
//jumpface=0;//跳跃方向-1	0	1
state=0;//状态0移动 1出招 2收招
timer=0;//状态计时器
hp=9;//血
//***固有
image_speed=0;//动画速度=0
```

### 玩家左右移动，坐标限制

为obj_player添加步事件

```GML
//***临时变量
var dx,psp,tmp;
dx=0;//左右按键状态
psp=0.75;//移动速度
//***按键判断
if(state==0&&jump==0)
{
	//右移动
	if(keyboard_check(ord("D")))
	{
		dx=1;
		sprite_index=spr_player_walk;
		image_index+=0.25;
		face=1;
	}
	else//***左移动
	if(keyboard_check(ord("A")))
	{
		dx=-1;
		sprite_index=spr_player_walk;
		image_index+=0.25;
		face=-1;
	}
	else sprite_index=spr_player_stand;
}
//***坐标变化
x+=dx*psp;
//方向变化
if(dx!=0)image_xscale=face;
//***坐标限制
if(x<0)x=room_width;
if(x>room_width)x=0;
```

### 下砸动作状态实现 

在步事件中将下砸代码添加到按键判断代码区块中：

```GML
//***下砸
	if(keyboard_check_pressed(ord("J")))
	{
		state=1;
		timer=15;//动作持续15帧
		sprite_index=spr_player_chui;
	}
```

将敲击判断放在按键判断代码区块下方：

```GML
//***敲击判断
if(state==1)
{
	image_index+=0.2;
	//***敲击结束
	if(timer<=0)
	{
		state=0;
		sprite_index=spr_player_stand;
	}
	//***敲击结束
	tmp=collision_rectangle(x-12,y,x+12,y-28,obj_haishi,0,0);//需创建haishi对象
	if(tmp)
	if(tmp.state==0)
	{
			tmp.state=1;
			audio_play_sound(snd_chui,0,false);
	}
	timer-=1;
}
```

创建海狮对象(obj_haishi)，精灵为haishi_walk

### 跳跃动作,速度限制

将跳跃代码段加入按键检测代码块中，并且不能和下砸同时按因此需加else,下砸代码上面已经加过了

```GML
	//***下砸
	if(keyboard_check_pressed(ord("J")))
	{
		state=1;
		timer=15;//动作持续15帧
		sprite_index=spr_player_chui;
	}
	else//***跳跃
	if(keyboard_check_pressed(ord("K")))
	{
		face=dx;
		jump=1;
		direction=90;
		speed=4.5;
		gravity=0.2;
		audio_play_sound(snd_jump,0,false);
		sprite_index=spr_player_jump;
	}
```

在按键检测区块下面添加跳跃检测,obj_break还没建，在后面会创建，如需检测跳跃，可先创建个对象，先不加代码，brk是obj_break的成员变量

```GML
//***跳跃检测
if(jump==1)
{
	x+=face*0.4;
	if(speed>8)speed=8;
	//***上跳判断
	if(direction==90)
	{
		//***动画转换
		if(speed<1)
		{
			image_index=1;
		}
		//***敲墙检测
		tmp=collision_point(x,y-24,obj_wall_father,0,0);
		if(tmp)
		{
			//***被敲碎
			 if(tmp.sprite_index!=spr_wall_wudi)
			 {
				var tmp2;
				tmp2=instance_create_depth(tmp.x,tmp.y,100,obj_break);
				tmp2.sprite_index=tmp.brk;
				tmp2.face=image_xscale;
				with(tmp)instance_desttroy();
			 }
			 audio_play_sound(snd_ding,0,false);
			 speed=0;
			 image_index=1;
		}
	}
}
```

### 落地判断

在跳跃检测代码块中加入下落检测

```GML
//***下落检测
	if(direction==270)
	{
		//***跳跃中改变方向
		if(face==0)
		{
			if(keyboard_check(ord("A"))){face=-1;image_xscale=-1;}
			if(keyboard_check(ord("D"))){face=1;image_xscale=1;}
		}
		//***落地判断
		tmp=collision_point(x,y,obj_wall_father,0,0);
		if(tmp)
		{
			jump=0;
			speed=0;
			gravity=0;
			y=tmp.y-1;
			sprite_index=spr_player_stand;
		}
	}
```

### 创建碎砖

创建对象obj_break，添加创建事件

```GML
face=0;
direction=90;//方向
speed=3;
gravity=0.2;//重力
image_speed=0.2;//动画速度
```

添加步事件

```GML
x+=face;
```

添加其它事件->视野(view)->外部视野0(outside view 0)

```GML
instance_destroy(obj_break);
```

### 墙体对应碎砖的逻辑

之后为每个可被敲碎墙体对象添加创建事件，添加一行相似代码,如obj_wall_10

```GML
brk=spr_break_10;
```

### 顶砖判断

代码在上面跳跃检测中已添加好

### 脚下为空检测

在敲击判断代码块下方添加脚下判断代码块

```GML
//***脚下判断if(jump==0){	tmp=collision_point(x,y+1,obj_wall_father,0,0);	if(!tmp)	{		jump=1;		gravity=0.2;		sprite_index=spr_player_jump;		image_index=1;	}	}
```

### 视野控制

此处我没有按照教程视频中的视野跟随，第一是因为GMS2中没有view_yveiw这个数组了，我试了试view_yport和view_hport，但都没有什么效果，于是我就在房间编辑器中房间属性里的视野属性(viewport properties)设置了跟踪，将垂直边界(vertical border)设了100，个人感觉效果还好，就是下落时感觉稍微有点快。

### 背景音乐

创建对象obj_ctrl，添加创建事件

```GML
audio_stop_all();audio_play_sound(snd_music,0,true);
```

### 海狮与移动

为obj_haishi添加创建事件

```GML
face=1;state=0;image_speed=0.2;
```

添加步事件，我这里和教程不太一样，我添加了下落检测

```GML
//***死亡if(state==1){	gravity=0.2;	sprite_index=spr_haishi_dead;	exit;}//***自动移动x+=face*0.3;if(x<0)x=room_width;if(x>room_width)x=0;//***脚下判断if(collision_point(x-1,y+1,obj_wall_father,0,0)){	gravity=0;	speed=0;	y=collision_point(x-1,y+1,obj_wall_father,0,0).y-1;	}if(!collision_point(x-2,y+1,obj_wall_father,0,0)&&!collision_point(x+2,y+1,obj_wall_father,0,0)){		gravity=0.2;	sprite_index=spr_haishi_walk;	image_index=2;}if(!collision_point(x-1,y+1,obj_wall_father,0,0)&&!collision_point(x+1,y+1,obj_wall_father,0,0)){	face=-face;}//***改变方向image_xscale=face;
```

添加Other->Outsideroom事件

```GML
instance_destroy();
```

### 打海狮与碰到海狮

打海狮在上面下砸检测时已经添加，接下来添加碰到海狮，在敲击判断下添加

```GML
else//***碰撞海狮{	tmp=collision_rectangle(x-8,y,x+8,y-16,obj_haishi,0,0);	if(tmp)	if(tmp.state==0)	{		state=-1;		sprite_index=spr_player_dead;		image_speed=0.2;		speed=2;		gravity=0.2		direction=90;		audio_play_sound(snd_dead,0,false);	}}
```

### 结语

至此，教程内容已经结束，视频最后对海狮左右摇摆bug的修复在**海狮与移动的步事件中已经修改**即添加了下落检测，素材包里还有其他没用过的精灵，将来有机会再添加8，继续塔塔开了。









