package
{
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;	
	import flash.geom.Rectangle;
	import characterStatus;
	
	public class LinkEngine extends MovieClip
	{
		
		//월드작용변수///////////////////////////////////////////
		var gravityPoint=1;						// 중력값
		var barTarget:characterStatus = null;	// 보스몬스터바 타겟
		////////////////////////////////////////////////////
		
		//카운트변수//////////////////////////////////////////
		var blockCount = 0; //지형수
		////////////////////////////////////////////////////
		
		//스위치///////////////////////////////////////////
		var leftKeyUP;
		var rightKeyUP;
		var spaceKeyUP;
		var zKeyUP;
		////////////////////////////////////////////////////
		
		var playerTimer:Timer;			// 플레이어 타이머
		var monsterTimer:Timer;		// 몬스터 타이머
		var BMHealthBarTimer:Timer; 	// 보스몬스터 체력바 타이머
		var moveTimer:Timer;  			// 케릭터 이동 타이머
		
		var player1:characterStatus;
		var monster1:characterStatus;
		var monster2:characterStatus;
		
		public function LinkEngine():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, KeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, KeyUp);
			
			playerTimer = new Timer(0);
			playerTimer.addEventListener(TimerEvent.TIMER, playerEnterFrame);
			playerTimer.start();
			
			monsterTimer = new Timer(0);
			monsterTimer.addEventListener(TimerEvent.TIMER, monsterEnterFrame);
			monsterTimer.start();
			
			moveTimer = new Timer(0);
			moveTimer.addEventListener(TimerEvent.TIMER, KeyDownToMove);
			moveTimer.start();
			
			var monsterObject:MovieClip  =  (root as MovieClip).monster;
			var monsterObject2:MovieClip =  (root as MovieClip).monster3;
			var playerObject:MovieClip   =  (root as MovieClip).player;
			
			player1  = new characterStatus(playerObject);
			player1.powerPoint = 30;
			
			monster1 = new characterStatus(monsterObject);
			monster1.healthPoint = 1500;
			monster1.health = 1500;
			monster1.characterName = "TestMonster1";
			monster1.backPoint = 900;
			
			monster2 = new characterStatus(monsterObject2);
			monster2.healthPoint = 1800;
			monster2.health = 1800;
			monster2.characterName = "TestMonster2";
			monster2.backPoint = 600;
			
			blockCount = objectCount("block");
			
		}// constructor code
		
		//전체작용//////////////////////////////////////////////////////////////////////////////////////////
		
		public function objectCount(objectName:String):Number
		{
			var i=1;
			var objectCount=0;
			do{
				if(root.hasOwnProperty(objectName+i)==false) break;
				else										 objectCount++;
				i++;
			}while(1);
			
			return objectCount;
		}//function objectCount- 무비클립의 오브젝트 수를 카운트 해주는 함수(오브젝트의 이름은 mon1 식으로 뒤에 숫자가 붙어야 한다, 1부터시작)
				
		public function test()
		{
			trace("테스트완료");
		}
		
		public function gravity(object:characterStatus):void
		{
			var block:MovieClip;
			var blockBounds:Rectangle;
			
			var characterObject :MovieClip = object.characterObject;
			var moveHitBox		:MovieClip = characterObject.moveHitBox;
			var objectBounds	:Rectangle = moveHitBox.getBounds(this);
			
			characterObject.y 	  	 += object.accelerationPoint; //중력작용
			object.accelerationPoint  = object.accelerationPoint+gravityPoint; //가속도 증가
				
			
			for(var i=1; i<=blockCount; i++){
				block 		= (root as MovieClip)["block"+i];
				blockBounds = block.getBounds(stage);
				
				if(block.hitTestObject(moveHitBox)){
					if(objectBounds.bottom >= blockBounds.top && objectBounds.bottom <= block.y){ //케릭터가 바닥위에 있고 벽 중점보다 위에있음
						characterObject.y = blockBounds.top - (characterObject.height/2);
						object.accelerationPoint = 0;
						object.jumpSwitch 		 = false;
					}else if(objectBounds.top >= blockBounds.bottom && objectBounds.bottom >= block.y && object.jumpSwitch) { //케릭터가 바닥아래에 있고 점프상태일경우
						//trace("블록위 y좌표 : ",blockBounds.top, " 케릭터아래 y좌표 : ", objectBounds.bottom);
						characterObject.y = blockBounds.bottom + (characterObject.height/2)+1;//+1은 버그방지
						object.accelerationPoint = 0;
					}
				}
			}
		}//function gravity - 지속적인 중력작용
		
		private function blockHitX(hitObject:characterStatus):Boolean
		{
			var block:MovieClip;
			var blockBounds :Rectangle;
			var moveHitBox	:MovieClip = hitObject.characterObject.moveHitBox;
			var objectBounds:Rectangle = moveHitBox.getBounds(this);
			
			for(var i=1; i<=blockCount; i++){
				block 		 = root["block" + i];
				blockBounds  = block.getBounds(stage);
				/*
				trace("블럭LEFT : ", blockBounds.left, "블럭RIGHT : ", blockBounds.right);
				trace("오브젝트LEFT : ", objectBounds.left, "오브젝트RIGHT: ", objectBounds.right);
				trace("블럭TOP : ", blockBounds.top, "오브젝트 bottom : ", objectBounds.bottom);
				*/
				if(moveHitBox.hitTestObject(block) && blockBounds.top+20 < objectBounds.bottom){ //오브젝트가 벽아래에 있을때만 체크(+20은 오차대비)
					if(blockBounds.left < objectBounds.right && blockBounds.left > objectBounds.left){ //벽 왼쪽에 부딪쳤을때
						//trace("왼쪽벽 박음!");
						hitObject.characterObject.x -= (objectBounds.right - blockBounds.left); //blockBounds.left - (hitObject.width/2); //blockBounds.left)+10; // 스턴효과 때문에 y히트와는 로직이 다름
						if(hitObject.nowState == "hit") hitObject.backPoint = blockBounds.left - (hitObject.characterObject.width);
						return true;
						
					}else if(blockBounds.right > objectBounds.left && blockBounds.right < objectBounds.right){ //벽 오른쪽에 부딪쳤을때
						//trace("오른쪽벽 박음!");
						hitObject.characterObject.x += (blockBounds.right - objectBounds.left);//blockBounds.right + (hitObject.characterObject.width/2); //objectBounds.left
						if(hitObject.nowState == "hit") hitObject.backPoint = blockBounds.right + (hitObject.characterObject.width);
						return true;
					}
				}
			}
			return false;
		}//function blockHitX - 블럭에대한 x축 충돌처리
		
		private function damageEffectPlay(object:MovieClip, damageNumber:Number):void
		{
			var effect:MovieClip = new damageEffect();
			effect.x = object.x;
			effect.y = object.y;
			effect.damage.damageLabel.text = damageNumber;
			addChild(effect);
		}//function HitEffectPlay - 피격시의 이펙트 재생
		
		private function HitEffectPlay(object:MovieClip):void
		{
			var effect:MovieClip = new effectTest();
			var rect:Rectangle   = object.getBounds(stage);
			//(rect.right-rect.left)
			effect.x = (Math.random()*rect.width)+rect.left;
			effect.y = (Math.random()*rect.height)+rect.top;
			addChild(effect);
		}//function HitEffectPlay - 이펙트 재생
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		//플레이어////////////////////////////////////////////////////////////////////////////////////
		
		public function playerEnterFrame(e:TimerEvent):void
		{
			gravity(player1);
		}//function playerEnterFrame - 플레이어에 대한 매초 작용점
		
		private function KeyDown(e:KeyboardEvent):void
		{
			var keyCode = e.keyCode
			
			if ( keyCode == Keyboard.LEFT	) leftKeyUP 	= true;
			if ( keyCode == Keyboard.RIGHT	) rightKeyUP 	= true;
			
			if ( keyCode == Keyboard.SPACE && player1.jumpSwitch==false ){
				spaceKeyUP = true;
				player1.accelerationPoint 	= -player1.jumpPoint; //점프!!
				player1.jumpSwitch 			= true;
			}
			
			if ( keyCode == Keyboard.Z	){
				// zKey = true;
				player1.attackSwitch = true;
				player1.characterObject.gotoAndStop(3);
			}
		}//function KeyDown - 키보드 이벤트(눌렀을시)
		
		private function KeyDownToMove(e:TimerEvent):void
		{
			var keyMoveObject:MovieClip = player1.characterObject;
			var playerscaleX = keyMoveObject.scaleX;
			blockHitX(player1);
			
			if(leftKeyUP && keyMoveObject.x >= 0){
				if(playerscaleX>0) keyMoveObject.scaleX *= -1; //위치반전
				//player1.characterObject.scaleX = -1;
				player1.characterObject.gotoAndStop(2);
				keyMoveObject.x -= player1.speedPoint;
			}
			
			if(rightKeyUP && keyMoveObject.x <= 1920){
				if(playerscaleX<0) keyMoveObject.scaleX *= -1; //위치반전
				//player1.characterObject.scaleX = 1;
				player1.characterObject.gotoAndStop(2);
				keyMoveObject.x += player1.speedPoint;
			}
			
		}//function KeyDownToMove - 키보드 눌렀을시 케릭터 이동 타이머
		
		private function KeyUp(e:KeyboardEvent):void
		{
			var keyCode = e.keyCode;
			if ( keyCode == Keyboard.RIGHT	) rightKeyUP 	= false;
			if ( keyCode == Keyboard.LEFT	) leftKeyUP 	= false;
			if ( keyCode == Keyboard.SPACE	) spaceKeyUP  	= false;
			//if ( keyCode == Keyboard.Z	) zKeyUP 		= false;
			
			if(keyCode == 39 || keyCode == 37) player.gotoAndStop(1);
			/*if( moveTimer != null ){
				moveTimer.stop();
				moveTimer.removeEventListener(TimerEvent.TIMER, KeyDownToMove);
				moveTimer = null;
			}*/
		}//function KeyUp - 키보드 이벤트(뗐을시)
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		//적////////////////////////////////////////////////////////////////////////////////////////////
		public function monsterEnterFrame(e:TimerEvent):void
		{
			gravity(monster1);
			gravity(monster2);
			monsterHit(monster1);
			monsterHit(monster2);
			blockHitX(monster1);
			blockHitX(monster2);
			monster1.characterObject.x  = monster1.characterObject.x + 0.1*(monster1.backPoint-monster1.characterObject.x);
			monster2.characterObject.x  = monster2.characterObject.x + 0.1*(monster2.backPoint-monster2.characterObject.x);
		}
		
		public function monsterHit(hitMonster:characterStatus):void
		{
			var playerHit:MovieClip = player1.characterObject.playerHit; //히트모션 무비클립이 존재하는지 판단을 위함
			var playerHitBox:MovieClip;
			var hitMonsterObject = hitMonster.characterObject; //히트몬스터의 무비클립
			
			if(playerHit != null) playerHitBox = playerHit.hitBox; //존재하면 그안의 hitBox를 찾음
			if(playerHitBox != null) { //hitBox도 존재하면 충돌처리
				if(hitMonsterObject.hitTestObject(playerHitBox) && hitMonster.health > 0 && hitMonster.nowState != "hit"){
					
					var bossMonsterBar:MovieClip = (root as MovieClip).bossMonsterBar;
					var barMask:MovieClip = bossMonsterBar.barMask;
					
					hitMonster.health -= player1.powerPoint;
					
					HitEffectPlay(hitMonsterObject); //이펙트재생
					damageEffectPlay(hitMonsterObject, player1.powerPoint);//데미지 이펙트
					
					if(hitMonsterObject.x > player1.characterObject.x) 	hitMonster.backPoint = hitMonsterObject.x+50; //스턴(아직 로직없음)
					else												hitMonster.backPoint = hitMonsterObject.x-50; //스턴(아직 로직없음)
					
					hitMonster.nowState = "hit";
					hitMonster.notDamageTimerStart();
					
					if(hitMonster.rating == "boss"){
						if(BMHealthBarTimer==null) {
							
							BMHealthBarTimer = new Timer(0, 100);//두번째 파라미터는 대기시간
							BMHealthBarTimer.addEventListener(TimerEvent.TIMER, BMHealthBar);
							BMHealthBarTimer.start();
							
							bossMonsterBar.alpha = 1;
							bossMonsterBar.monsterNameLabel.text = hitMonster.characterName;
							bossMonsterBar.maxHealthLabel.text = hitMonster.healthPoint;
							bossMonsterBar.healthLabel.text = hitMonster.health;
							
						} else {
							bossMonsterBar.monsterNameLabel.text = hitMonster.characterName;
							bossMonsterBar.maxHealthLabel.text = hitMonster.healthPoint;
							bossMonsterBar.healthLabel.text = hitMonster.health;
							BMHealthBarTimer.reset();
							BMHealthBarTimer.start();
						}
						
						if( barTarget != hitMonster ){
							var temp = hitMonster.health/hitMonster.healthPoint; //피격률 계산
							barTarget = hitMonster;
							barMask.scaleX = temp;
						}// if - 보스몬스터 생명바 타켓변경
						
					}
					
					if(hitMonster.health <= 0){
						removeChild(hitMonsterObject);
						hitMonster = null;
					}// if - 체력소진 몬스터 객체 삭제
				}//if - 충돌처리(피격시 6번이나 충돌처리되는 버그있음)
			}
		}//function monsterHit - 몬스터 피격시 처리
		
		public function BMHealthBar(e:TimerEvent):void
		{
			var temp = barTarget.health/barTarget.healthPoint;
			var bossMonsterBar:MovieClip = (root as MovieClip).bossMonsterBar;
			var barMask:MovieClip = bossMonsterBar.barMask;
			barMask.scaleX =  barMask.scaleX + 0.1*(temp-barMask.scaleX);

			if( BMHealthBarTimer.currentCount == BMHealthBarTimer.repeatCount && BMHealthBarTimer!=null ) {
				bossMonsterBar.alpha = 0;
				BMHealthBarTimer.stop();
				BMHealthBarTimer.removeEventListener(TimerEvent.TIMER, BMHealthBar);
				BMHealthBarTimer = null;
			}			
		}//function BMHealthBar - 보스 하트바 타이머
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
	}
}