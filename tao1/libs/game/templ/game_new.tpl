
<!DOCTYPE html>

<script src='vendor/three.js/build/three.js'></script>
<script src='vendor/three.js/examples/js/libs/stats.min.js'></script>
<script src='vendor/three.js/examples/js/libs/tween.min.js'></script>
<script src="vendor/require.js/require.js"></script>
<script src="vendor/three.js/examples/js/Detector.js"></script>
<script src="vendor/threex.windowresize.js"></script>

<!-- include three.js postprocessing  -->
<script src="vendor/three.js/examples/js/postprocessing/EffectComposer.js"></script>
<script src="vendor/three.js/examples/js/postprocessing/RenderPass.js"></script>
<script src="vendor/three.js/examples/js/postprocessing/ShaderPass.js"></script>
<script src="vendor/three.js/examples/js/postprocessing/MaskPass.js"></script> 
<script src="vendor/three.js/examples/js/shaders/CopyShader.js"></script>

<script src="vendor/three.js/examples/js/libs/dat.gui.min.js"></script>

<script src='../threex.stellar7tankmodel.js'></script>
<script src='../threex.stellar7tankcontrols.js'></script>
<script src='../threex.stellar7tankcontrolsvirtualjoystick.js'></script>
<script src='../threex.stellar7tankcontrolskeyboard.js'></script>
<script src='../threex.stellar7tankcontrolsqueue.js'></script>
<script src='../threex.stellar7tankbody.js'></script>
<script src='../threex.stellar7bulletmodel.js'></script>
<script src='../threex.stellar7bulletbody.js'></script>
<script src='threex.stellar7game.js'></script>
<script src='threex.stellar7map.js'></script>
<script src='threex.stellar7minimap.js'></script>
<script src='threex.lightpool.js'></script>
<script src='threex.sphericalblastemitter.js'></script>

<link rel='canonical' href="http://jeromeetienne.github.io/stellar7/"/>

<!-- to disable zoom on mobile -->
<meta content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0' name='viewport' />
<meta name="viewport" content="width=device-width" />

<style>
body{ -webkit-user-select	: none; -moz-user-select	: none; }
</style>
<body style='margin: 0; padding: 0; overflow: hidden; background-color: #000000;'>
<style>
@font-face {	/* for mute button which is part of awesome font */
	font-family: 'FontAwesome';
	src: url('vendor/Font-Awesome/font/fontawesome-webfont.eot?v=3.2.1');
	src: url('vendor/Font-Awesome/font/fontawesome-webfont.eot?#iefix&v=3.2.1') format('embedded-opentype'), url('vendor/Font-Awesome/font/fontawesome-webfont.woff?v=3.2.1') format('woff'), url('vendor/Font-Awesome/font/fontawesome-webfont.ttf?v=3.2.1') format('truetype'), url('vendor/Font-Awesome/font/fontawesome-webfont.svg#fontawesomeregular?v=3.2.1') format('svg');
	font-weight: normal;
	font-style: normal;
}
</style>
<!-- include Score html -->	
<style>
.osdFont { font-family	: arial, verdana, sans-serif; font-size	: 200%; font-weight	: bolder; transition		: opacity 0.5s ease; -webkit-transition	: opacity 0.5s ease; color		: #000; text-shadow	: 0 0 0.2em #fbc, 0 0 0.2em #fbc, 0 0 0.2em #fbc; }
.osdVisible { opacity: 1 }
.osdHidden { opacity: 0 }
</style>
<style>
#osdLeftColumn { position	: absolute; text-align	: left; top		: 0; left		: 0; padding-left	: 10px; }
#osdRightColumn { position	: absolute; text-align	: right; top		: 0; right		: 0; padding-right	: 10px; }
#osdCenterColumn { position	: absolute; top		: 30%; text-align	: center; width		: 100%; }
</style>
<style>
.clickableOsd { padding: 4px; margin: 4px; }
.clickableOsd:hover { background-color: rgba(255,0,0,0.5); border-radius	: 6px; pointer		: 'hand'; }
#muteOsd { font-family: FontAwesome; }
#muteOsd:before { content: "\f028";	/* icon for non mute */ }
#muteOsd.muted:before { content: "\f026";	/* icon for muted */ }
#renderingProfileDomElement { font-size: 150%; }
#soundTrackDomElement { font-size: 150%; }
</style>
<div id='osdLeftColumn'>
	<div class='osdFont'> Score: <span id="scoreDomElement">00000</span></div>
	<div class='osdFont'> Energy: <span id="energyDomElement">1000</span></div>
	<div class='osdFont'> Lives: <span id="livesDomElement">3</span></div>
</div>
<div id='osdRightColumn'>
	<div class='osdFont clickableOsd' id="renderingProfileDomElement"> Graphics: <span>High</span></div>
	<div class='osdFont clickableOsd' id="soundTrackDomElement"> SoundTrack: <span>On</span></div>
	<div id="muteOsd" class='osdFont clickableOsd'></div>
</div>
<div id='osdCenterColumn'>
	<div id="gameStartOsd" class='osdFont osdHidden'>Ready ?</div>
	<div id="gameLostOsd" class='osdFont osdHidden'>Game Over!</div>
	<div id="hitByBulletOsd" class='osdFont osdHidden'>Ouch</div>
	<div id="spawnPlayerOsd" class='osdFont osdHidden'>GO!</div>
	<div id="killPlayerOsd" class='osdFont osdHidden'>You Die!</div>
</div>
<script>
require([ 'bower_components/threex.keyboardstate/package.require.js'
	, 'bower_components/threex.spaceships/package.require.js'
	, 'bower_components/threex.planets/package.require.js'
	, 'bower_components/threex.montainsarena/package.require.js'
	, 'bower_components/threex.nyancat/package.require.js'
	, 'bower_components/webaudiox/build/webaudiox.js'
	, 'bower_components/threex.badtvpproc/package.require.js'
	, 'bower_components/threex.geometricglow/package.require.js'
	, 'bower_components/threex.solidwireframe/threex.solidwireframe.js'
	, 'bower_components/threex.coloradjust/package.require.js'
	, 'vendor/gowiththeflow.js'
	, 'bower_components/virtualjoystick.js/virtualjoystick.js'
	], function(){
		
	//////////////////////////////////////////////////////////////////////////////////
	//		renderingProfile						//
	//////////////////////////////////////////////////////////////////////////////////
	
	var renderingProfiles	= []
	renderingProfiles['desktop_high']	= {
		devicePixelRatio	: 1,
		miniMapEnabled		: true,
		displayPlanets		: true,
		displayStarfield	: true,
		displayMontainArena	: true,
		groundMaterial		: 'phong',
		postProcessing		: true,
		badTvPasses		: true,
		colorPasses		: true,
		alphaTestBuggy		: false,
	}
	renderingProfiles['desktop_low']	= {
		devicePixelRatio	: 1/2,
		miniMapEnabled		: true,
		displayPlanets		: true,
		displayStarfield	: true,
		displayMontainArena	: true,
		groundMaterial		: 'lambert',
		postProcessing		: true,
		badTvPasses		: false,
		colorPasses		: true,
		alphaTestBuggy		: true,
	}
	renderingProfiles['mobile_high']	= {
		devicePixelRatio	: 1/2,
		miniMapEnabled		: false,
		displayPlanets		: false,
		displayStarfield	: false,
		displayMontainArena	: true,
		groundMaterial		: 'lambert',
		postProcessing		: true,
		badTvPasses		: false,
		colorPasses		: true,
		alphaTestBuggy		: false,
	}
	renderingProfiles['mobile_low']	= {
		devicePixelRatio	: 1/2,
		miniMapEnabled		: false,
		displayPlanets		: false,
		displayStarfield	: false,
		displayMontainArena	: true,
		groundMaterial		: 'lambert',
		postProcessing		: true,
		badTvPasses		: false,
		colorPasses		: true,
		alphaTestBuggy		: false,
	}
	
	;(function(){
		// default to high quality
		var quality	= 'high'
		
		// get it from localStorage if it exists
		if( localStorage.getItem("graphics_quality") !== null ){
			quality	= localStorage.getItem("graphics_quality")
		}
		// save it in localStorage
		localStorage.setItem("graphics_quality", quality)
	
		// pick a renderingProfile based on quality and category
		var onMobile	= 'ontouchstart' in window ? true : false
		var category	= onMobile ? 'mobile' : 'desktop'
		var profileName	= category + '_' + quality
		
		// set the renderingProfile
		window.renderingProfile	= renderingProfiles[profileName]		

		// handl teh
		var element	= document.querySelector('#renderingProfileDomElement span')
		element.innerText	= quality === 'high' ? 'High' : 'Low'
		document.querySelector('#renderingProfileDomElement').addEventListener('click', function(){
			// toggle the quality
			quality	= quality === 'high' ? 'low' : 'high'
			// update the screen
			element.innerText	= quality === 'high' ? 'High' : 'Low'
			// save the value
			localStorage.setItem("graphics_quality", quality)
			// reload the page
			location.reload()
		})
	})()

	//////////////////////////////////////////////////////////////////////////////////
	//		three.js init							//
	//////////////////////////////////////////////////////////////////////////////////
	
	// detect WebGL
	if( !Detector.webgl ){
		Detector.addGetWebGLMessage();
		throw 'WebGL Not Available'
	}
	// setup webgl renderer full page
	var renderer	= new THREE.WebGLRenderer();

	renderer.devicePixelRatio	= renderingProfile.devicePixelRatio

	renderer.setSize( window.innerWidth, window.innerHeight );
	renderer.domElement.style.zIndex	= -1
	document.body.appendChild( renderer.domElement );
	// setup a scene and camera
	var scene	= new THREE.Scene();
	var camera	= new THREE.PerspectiveCamera(90, window.innerWidth / window.innerHeight, 0.01, 100);
	camera.position.z = 3;

	// declare the rendering loop
	var onRenderFcts= [];

	// handle window resize events
	var winResize	= new THREEx.WindowResize(renderer, camera)

	window.Stellar7	= {}

	//////////////////////////////////////////////////////////////////////////////////
	//		default 3 points lightning					//
	//////////////////////////////////////////////////////////////////////////////////
	
	var ambientLight= new THREE.AmbientLight( 0x020202 )
	scene.add( ambientLight)
	var frontLight	= new THREE.DirectionalLight('white', 1)
	frontLight.position.set(0.5, 0.5, 2)
	scene.add( frontLight )
	var backLight	= new THREE.DirectionalLight('white', 0.75)
	backLight.position.set(-0.5, -0.5, -2)
	scene.add( backLight )		


	//////////////////////////////////////////////////////////////////////////////////
	//		comment								//
	//////////////////////////////////////////////////////////////////////////////////
	
	var lightPool	= new THREEx.LightPool(scene, NaN)
	Stellar7.lightPool	= lightPool

	//////////////////////////////////////////////////////////////////////////////////
	//		add an object and make it move					//
	//////////////////////////////////////////////////////////////////////////////////	

	var game	= new THREEx.Stellar7Game(scene)
	onRenderFcts.push(function(delta, now){
		game.update(delta, now)
	})
	Stellar7.game	= game


	var humanPlayer	= null
;(function(){
	var tankBody	= new THREEx.Stellar7TankBody()
	game.addTankKeyboard(tankBody)
	
	// tankBody.maxEnergy	= 250
	// tankBody.energy		= tankBody.maxEnergy
	// tankBody.maxLives	= 0
	// tankBody.lives		= 0
	tankBody.model.object3d.position.x	+= 2

	// tankBody.resetPosition(game.map)

	tankBody.model.setFaceColor('black')
	tankBody.model.setLineColor('cyan')
	tankBody.model.setLineWidth(10)

	humanPlayer		= tankBody
	Stellar7.humanPlayer	= tankBody
	
	
})()

;(function(){
	var emitter	= new THREEx.SphericalBlastEmitter(scene);
	onRenderFcts.push(function(delta, now){
		emitter.update(delta, now)
	})
	document.addEventListener('emitSphericalBlast', function(event){
		var position	= event.detail.position
		var color	= event.detail.color
		var maxRadius	= event.detail.maxRadius
		var maxAge	= event.detail.maxAge
		emitter.emit(position, color, maxRadius, maxAge);
	})
})()

	// setInterval(function(){
	// 	document.dispatchEvent(new CustomEvent('emitSphericalBlast', {detail:{
	// 		position	: new THREE.Vector3(0,0,0),
	// 		color		: 'red',
	// 		maxRadius	: 1.2,
	// 		maxAge		: 1.5,
	// 	}}))
	// }, 1000*2)

	//////////////////////////////////////////////////////////////////////////////////
	//		tween.js update							//
	//////////////////////////////////////////////////////////////////////////////////
	
	onRenderFcts.push(function(delta, now){
		TWEEN.update();
	})

	//////////////////////////////////////////////////////////////////////////////////
	//		comment								//
	//////////////////////////////////////////////////////////////////////////////////
			
	var nBots	= 4		
	// var nBots	= 0
	for(var i = 0; i < nBots; i++){
		;(function(){
			var tankBody	= new THREEx.Stellar7TankBody()

			tankBody.lives	= 9999	// infinite lives
			tankBody.model.setFaceColor('darkred')
			tankBody.model.setLineColor('pink')
			tankBody.model.setLineWidth(2)
			
			game.addTankQueue(tankBody)

			tankBody.resetPosition(game.map)
			
			tankBody.addEventListener('scannedTank', function(){
				tankBody.controls.fire()
			})
			tankBody.controls.addEventListener('idle', function(){
				if( Math.random() < 0.5 ){
					tankBody.controls.push('turnRight', 1)		
				}else{
					tankBody.controls.push('turnLeft', 1)
				}
				if( Math.random() < 0.5 ){
					tankBody.controls.push('moveAhead', 1)
				}
				if( Math.random() < 0.25 ){
					tankBody.controls.push('moveAhead', 1)
				}
			})
		})()
	}
	//////////////////////////////////////////////////////////////////////////////////
	//		comment								//
	//////////////////////////////////////////////////////////////////////////////////
	;(function(){
		// the domElement to update
		var domElement	= document.querySelector('#scoreDomElement')
		// the lastRendered value is cached for efficiency
		var lastRendered= null
		// function to refreshScore if needed
		function refreshScore(){
			var score	= humanPlayer.score
			if( score === lastRendered )	return
			
			var str		= stringPadder(score, 5, '0')
			domElement.innerHTML	= str

			function stringPadder(value, width, padChar){
				var maxPadded	= Array(width+1).join(padChar) + value;
				return maxPadded.substr(maxPadded.length-width);
			}	
		}
		// init first one
		refreshScore()
		// update periodically
		onRenderFcts.push(function(delta, now){
			refreshScore();
		})
	})()

	//////////////////////////////////////////////////////////////////////////////////
	//		comment								//
	//////////////////////////////////////////////////////////////////////////////////
	;(function(){
		// the domElement to update
		var domElement	= document.querySelector('#energyDomElement')
		// the lastRendered value is cached for efficiency
		var lastRendered= null
		// function to refreshScore if needed
		function refreshScore(){
			var energy	= humanPlayer.energy
			if( energy === lastRendered )	return
			
			var str		= stringPadder(energy, 5, ' ')
			domElement.innerHTML	= str

			function stringPadder(value, width, padChar){
				var maxPadded	= Array(width+1).join(padChar) + value;
				return maxPadded.substr(maxPadded.length-width);
			}	
		}
		// init first one
		refreshScore()
		// update periodically
		onRenderFcts.push(function(delta, now){
			refreshScore();
		})
	})()

	//////////////////////////////////////////////////////////////////////////////////
	//		comment								//
	//////////////////////////////////////////////////////////////////////////////////
	;(function(){
		// the domElement to update
		var domElement	= document.querySelector('#livesDomElement')
		// the lastRendered value is cached for efficiency
		var lastRendered= null
		// function to refreshScore if needed
		function refreshScore(){
			var lives	= humanPlayer.lives
			if( lives === lastRendered )	return
			
			var str		= stringPadder(lives, 1, '0')
			domElement.innerHTML	= str

			function stringPadder(value, width, padChar){
				var maxPadded	= Array(width+1).join(padChar) + value;
				return maxPadded.substr(maxPadded.length-width);
			}	
		}
		// init first one
		refreshScore()
		// update periodically
		onRenderFcts.push(function(delta, now){
			refreshScore();
		})
	})()

	//////////////////////////////////////////////////////////////////////////////////
	//		Camera Controls							//
	//////////////////////////////////////////////////////////////////////////////////
	// var mouse	= {x : 0, y : 0}
	// document.addEventListener('mousemove', function(event){
	// 	mouse.x	= (event.clientX / window.innerWidth ) - 0.5
	// 	mouse.y	= (event.clientY / window.innerHeight) - 0.5
	// }, false)
	// onRenderFcts.push(function(delta, now){
	// 	camera.position.x += (mouse.x*5 - camera.position.x) * (delta*3)
	// 	camera.position.y += (mouse.y*5 - camera.position.y) * (delta*3)
	// 	camera.lookAt( scene.position )
	// })
	
	//////////////////////////////////////////////////////////////////////////////////
	//		put camera behind						//
	//////////////////////////////////////////////////////////////////////////////////
	
	humanPlayer.model.cannonMesh.add(camera)
	camera.position.set(0,0.3,-0.9)
	camera.lookAt(new THREE.Vector3(0,0,2))


	//////////////////////////////////////////////////////////////////////////////////
	//		map								//
	//////////////////////////////////////////////////////////////////////////////////
	
	if( renderingProfile.miniMapEnabled ){
		var miniMap	= new THREEx.Stellar7MiniMap(game)
		onRenderFcts.push(function(delta,now){
			miniMap.update(delta, now)
		})
		document.body.appendChild(miniMap.domElement)
		miniMap.domElement.style.position	= 'absolute'
		miniMap.domElement.style.left		= '1em'
		miniMap.domElement.style.bottom		= '1em'		
	}
	
	//////////////////////////////////////////////////////////////////////////////////
	//		gamesounds							//
	//////////////////////////////////////////////////////////////////////////////////

	var gameSounds	= new WebAudiox.GameSounds2()
	gameSounds.lineOut.volume	= 0.2
	gameSounds.follow(camera)
	onRenderFcts.push(function(delta){
		gameSounds.update(delta)
	})
	
	// handle mute UI
	document.querySelector('#muteOsd').addEventListener('click', function(event){
		// change sounds
		gameSounds.lineOut.toggleMute()
		// change display
		var element	= event.target
		element.classList.toggle("muted");
		// save 
		localStorage.setItem('isMuted', gameSounds.lineOut.isMuted ? 'muted' : 'no' )
	})
	if( localStorage.getItem('isMuted') === 'muted' ){
		var element	= document.querySelector('#muteOsd')
		element.classList.toggle("muted");
		gameSounds.lineOut.toggleMute()
	}
	

	// handle soundTrack UI
	document.querySelector('#soundTrackDomElement').addEventListener('click', function(event){
		var element	= document.querySelector('#soundTrackDomElement span')
		var soundTrackEnabled	= element.innerText === 'On' ? true : false
		// toggle it		
		soundTrackEnabled	= soundTrackEnabled === true ? false : true
		
		
		
		element.innerText	= soundTrackEnabled === true ? 'On' : 'Off'
		// save 
		localStorage.setItem('soundTrack', soundTrackEnabled ? 'enabled' : 'disabled' )

		soundTrack.gainNode.gain.value	= soundTrackEnabled ? 0.2 : 0
	})
	if( localStorage.getItem('soundTrack') !== null ){
		
		var soundTrackEnabled	= localStorage.getItem('soundTrack') === 'enabled'

		var element		= document.querySelector('#soundTrackDomElement span')
		element.innerText	= soundTrackEnabled === true ? 'On' : 'Off'
	}else{
		localStorage.setItem('soundTrack', 'enabled' )
	}

	//////////////////////////////////////////////////////////////////////////////////
	//		init soundBank							//
	//////////////////////////////////////////////////////////////////////////////////
	
// TODO this should be in THREEx.GameSounds
	var soundBank	= {}
	
	// sound track
	soundBank['soundTrack']	= gameSounds.createSound()
		.load('sounds/rezoner-7DFPS-2013-2.mp3', function(sound){
			var soundTrackEnabled	= localStorage.getItem('soundTrack') === 'enabled' ? true : false
			var utterance	= sound.play({
				loop	: true,
				volume	: soundTrackEnabled ? 0.2 : 0.0,
			})
			window.soundTrack	= utterance
		})
	
	soundBank['contactFence']		= gameSounds.createSound()
		.load('sounds/169689__beman87__impact-zap-2.wav')
	soundBank['bulletTank']		= gameSounds.createSound()
		.load('sounds/151022__bubaproducer__laser-shot-silenced.wav')

	soundBank['hitByBullet']		= gameSounds.createSound({
		volume	: 0.3	
	}).load('sounds/211234__rjonesxlr8__explosion-14.wav')

	soundBank['gameStart']			= gameSounds.createSound()
		.load('sounds/macsay-areyouready.wav')
	soundBank['intertank.collision']	= gameSounds.createSound()
		.load('sounds/95802__robinhood76__01670-electric-future-blast.wav')
	soundBank['localtankmap.collision']	= gameSounds.createSound()
		.load('sounds/95802__robinhood76__01670-electric-future-blast.wav')

	soundBank['gameOver']	= gameSounds.createSound()
		.load('sounds/macsay-gameover.wav')
	soundBank['gameOver2']	= gameSounds.createSound()
		.load('sounds/159408__noirenex__lifelost.wav')
		
	soundBank['enemyDead']		= gameSounds.createSound()
		.load('sounds/196841__omarstone__hahahaha-cartoon-monster.wav')
	soundBank['enemyExplode']	= gameSounds.createSound()
		.load('sounds/153445__lukechalaudio__8bit-robot-sound.wav')
		

	// document.dispatchEvent(new CustomEvent('playSound', { detail: {
	// 	label	: 'gameStart',
	// 	volume	: 0.5,
	// 	position: {},
	// 	follow: {},
	// }}));
	
	document.addEventListener('playSound', function(event){
		var label	= event.detail.label	|| console.assert(false)

		var options	= {}
		if( event.detail.position )	options.position= event.detail.position
		if( event.detail.follow )	options.follow	= event.detail.follow
		if( event.detail.volume )	options.volume	= event.detail.volume

		var sound	= soundBank[label]
		console.assert(sound !== undefined, 'tried to play unexisting sound :'+label)
		if( sound.loaded !== true )	console.warn('tried to play unloaded sound :'+label)
		if( sound.loaded !== true )	return

		sound.play(options)
	})

	
	//////////////////////////////////////////////////////////////////////////////////
	//		comment								//
	//////////////////////////////////////////////////////////////////////////////////

	document.addEventListener('gameStart', function(){ 
		var position	= humanPlayer.model.object3d.position 
		position.y	= 5;
		game.frozen	= true
		
		var osdElement	= document.querySelector('#gameStartOsd')
		Flow().seq(function(next){
			osdElement.classList.add("osdVisible");
			osdElement.classList.remove("osdHidden");
			next()
		}).seq(function(next){
			setTimeout(function(){
				document.dispatchEvent(new CustomEvent('playSound', { detail: {
					label	: 'gameStart',
				}}));
				next()
			}, 1000*0.5)
		}).seq(function(next){
			setTimeout(function(){
				next()
			}, 1000*1.5)
		}).seq(function(next){
			osdElement.classList.remove("osdVisible");
			osdElement.classList.add("osdHidden");
			next()
		}).seq(function(next){
			document.dispatchEvent(new CustomEvent('spawnPlayer'))
			next()	
		})
	})

	document.addEventListener('gameLost', function(){
		var tankBody	= humanPlayer;
		var position	= tankBody.model.object3d.position
		var rotation	= tankBody.model.object3d.rotation
		game.frozen	= true

		document.dispatchEvent(new CustomEvent('playSound', { detail: {
			label	: 'gameOver',
		}}));


		// cinematic
		var osdElement	= document.querySelector('#gameLostOsd')
		Flow().seq(function(next){
			osdElement.classList.add("osdVisible");
			osdElement.classList.remove("osdHidden");
			next()
		}).par(function(next){
			var tween	= new TWEEN.Tween(position).to({ y: 4, }, 4*1000).easing(TWEEN.Easing.Exponential.Out).onComplete(function(){ next() }).start()
		}).par(function(next){ var tween	= new TWEEN.Tween(rotation).delay(1000*2).to({ z: Math.PI, }, 1000*2).easing(TWEEN.Easing.Circular.In).onComplete(function(){ next() }).start()
		}).par(function(next){
			setTimeout(function(){
				document.dispatchEvent(new CustomEvent('playSound', { detail: { label	: 'gameOver2' }}));
				next()
			}, 1000*2)
		}).seq(function(next){ 
			setTimeout(function(){ next() }, 1000*1) }).seq(function(next){
			osdElement.classList.remove("osdVisible");
			osdElement.classList.add("osdHidden");
			next()
		}).seq(function(next){
			// game.frozen	= false
			next()
		}).seq(function(next){
			location.href	= '../'
			next()
		})
	})

	document.addEventListener('spawnPlayer', function(){
		var tankBody	= humanPlayer;
		var position	= tankBody.model.object3d.position
		position.y	= 5;
		game.frozen	= true

		// cinematic
		var osdElement	= document.querySelector('#spawnPlayerOsd')
		Flow().seq(function(next){
			osdElement.classList.add("osdVisible");
			osdElement.classList.remove("osdHidden");
			next()
		}).seq(function(next){
			var tween	= new TWEEN.Tween(position)
				.to({
					y	: 0,
				}, 2*1000)
				.easing(TWEEN.Easing.Exponential.InOut)
				.onComplete(function(){ next() })
				.start()
		}).seq(function(next){
			osdElement.classList.remove("osdVisible");
			osdElement.classList.add("osdHidden");
			game.frozen	= false
			next()
		})
	})

	document.addEventListener('killPlayer', function(event){
		var tankBody	= humanPlayer;
		game.frozen	= true
		document.dispatchEvent(new CustomEvent('BadTVJamming', { detail: {
			presetLabel	: 'strongScrolly'
		}}));

		// cinematic
		var osdElement	= document.querySelector('#killPlayerOsd')
		Flow().seq(function(next){
			osdElement.classList.add("osdVisible");
			osdElement.classList.remove("osdHidden");
			next()
		}).seq(function(next){
			setTimeout(function(){
				next()
			}, 1000*1.1)
		}).seq(function(next){
			osdElement.classList.remove("osdVisible");
			osdElement.classList.add("osdHidden");
			next()
		}).seq(function(next){
			tankBody.resetPosition(game.map)
			document.dispatchEvent(new CustomEvent('spawnPlayer'))
			next()
		})
	})

	//////////////////////////////////////////////////////////////////////////////////
	//		badTVPasses							//
	//////////////////////////////////////////////////////////////////////////////////
	
	var badTVPasses	= new THREEx.BadTVPasses();
	onRenderFcts.push(function(delta, now){
		badTVPasses.update(delta, now)		
	})
	badTVPasses.params.preset('resetInterlace')
	badTVPasses.onParamsChange();

	// THREEx.addBadTVPasses2DatGui(badTVPasses)

	//////////////////////////////////////////////////////////////////////////////////
	//		colorPasses							//
	//////////////////////////////////////////////////////////////////////////////////

	var colorPasses	= new THREEx.ColorAdjust.Passes();
	onRenderFcts.push(function(delta, now){
		colorPasses.update(delta, now)
	});
	colorPasses.delay	= 0.1
	document.addEventListener('colorAdjust', function(event){
		var colorCube	= event.detail.colorCube;
		colorPasses.setColorCube(colorCube)
	})

	//////////////////////////////////////////////////////////////////////////////////
	//		switch color cube randomly every 2 seconds			//
	//////////////////////////////////////////////////////////////////////////////////
	
	// setInterval(function(){
	// 	var values	= Object.keys(THREEx.ColorAdjust.colorCubes)
	// 	var index	= Math.floor(Math.random()*values.length)
	// 	var value	= values[index]
	// 	colorPasses.setColorCube(value)
	// }, 2*1000)

	//////////////////////////////////////////////////////////////////////////////////
	//		composer 							//
	//////////////////////////////////////////////////////////////////////////////////

	var composer	= new THREE.EffectComposer(renderer);
	var renderPass	= new THREE.RenderPass( scene, camera );
	composer.addPass( renderPass );

	// add colorPasses to composer	
	if( renderingProfile.colorPasses )	colorPasses.addPassesTo(composer)
	// add badTVPasses to composer	
	if( renderingProfile.badTvPasses )	badTVPasses.addPassesTo(composer)

	composer.passes[composer.passes.length -1 ].renderToScreen	= true;

	
	//////////////////////////////////////////////////////////////////////////////////
	//		ping animation + sounds						//
	//////////////////////////////////////////////////////////////////////////////////

	var badTVJamming	= new THREEx.BadTVJamming(badTVPasses, gameSounds.context, gameSounds.lineOut.destination)
	document.addEventListener('BadTVJamming', function(event){
		var presetLabel	= event.detail.presetLabel
		badTVJamming.preset(presetLabel)		
	})
	//////////////////////////////////////////////////////////////////////////////////
	//		launch the gameStart event					//
	//////////////////////////////////////////////////////////////////////////////////

	document.dispatchEvent(new CustomEvent('gameStart'))

	//////////////////////////////////////////////////////////////////////////////////
	//		stats.js							//
	//////////////////////////////////////////////////////////////////////////////////
	
	var stats	= new Stats()
	stats.domElement.style.position	= 'absolute'
	stats.domElement.style.bottom	= '0px'
	stats.domElement.style.right	= '0px'
	// stats.domElement.style.zoom	= '400%'
	document.body.appendChild(stats.domElement)
	onRenderFcts.push(function(delta, now){
		stats.update();		
	})

	//////////////////////////////////////////////////////////////////////////////////
	//		render the scene						//
	//////////////////////////////////////////////////////////////////////////////////
	onRenderFcts.push(function(delta, now){
		if( renderingProfile.postProcessing ){
			// render thru composer
			composer.render(delta)
		}else{
			// disable rendering directly thru renderer 
			renderer.render(scene, camera)		
		}
	});
	
	//////////////////////////////////////////////////////////////////////////////////
	//		Rendering Loop runner						//
	//////////////////////////////////////////////////////////////////////////////////
	var lastTimeMsec= null
	requestAnimationFrame(function animate(nowMsec){
		// keep looping
		requestAnimationFrame( animate );
		// measure time
		lastTimeMsec	= lastTimeMsec || nowMsec-1000/60
		var deltaMsec	= Math.min(200, nowMsec - lastTimeMsec)
		lastTimeMsec	= nowMsec
		// call each update function
		onRenderFcts.forEach(function(onRenderFct){
			onRenderFct(deltaMsec/1000, nowMsec/1000)
		})
	})
})











function KeyboardControls(object, options) {
    this.object = object;
    options = options || {};
    this.domElement = options.domElement || document;
    this.moveSpeed = options.moveSpeed || 1;
}
this.domElement.addEventListener('keydown', this.onKeyDown.bind(this), false);
this.domElement.addEventListener('keyup',   this.onKeyUp.bind(this), false);
KeyboardControls.prototype = {
    update: function() {
        if (this.moveForward)   this.object.translateZ(-this.moveSpeed);
        if (this.moveBackward)  this.object.translateZ( this.moveSpeed);
        if (this.moveLeft)      this.object.translateX(-this.moveSpeed);
        if (this.moveRight)     this.object.translateX( this.moveSpeed);
    },
    onKeyDown: function (event) {
        switch (event.keyCode) {
            case 38: /*up*/    case 87: /*W*/ this.moveForward =  true; break;
            case 37: /*left*/  case 65: /*A*/ this.moveLeft =     true; break;
            case 40: /*down*/  case 83: /*S*/ this.moveBackward = true; break;
            case 39: /*right*/ case 68: /*D*/ this.moveRight =    true; break;
        }
    },
    onKeyUp: function (event) {
        switch(event.keyCode) {
            case 38: /*up*/    case 87: /*W*/ this.moveForward =  false; break;
            case 37: /*left*/  case 65: /*A*/ this.moveLeft =     false; break;
            case 40: /*down*/  case 83: /*S*/ this.moveBackward = false; break;
            case 39: /*right*/ case 68: /*D*/ this.moveRight =    false; break;
        }
    }
};



window.addEventListener("keydown", function(e){ if (localPlayer)  keys.onKeyDown(e);  }, false);
window.addEventListener("keyup",   function(e){ if (localPlayer)  keys.onKeyUp(e);    }, false);
{#                                                                    ||    #}
{#                                                                    \/    #}
                                                                var onKeyDown = function(e) {
                                                                    var that = this;
                                                                    switch (e.keyCode) {
                                                                        case 37: case 65: that.left  = true; break;
                                                                        case 38: case 87: that.up    = true; break;
                                                                        case 39: case 68: that.right = true; break;
                                                                        case 40: case 83: that.down  = true; break;
                                                                    }
                                                                };
keys = new Keys();


	if (localPlayer.update(keys))
		ws.send( JSON.stringify({'e':'move', 'x':localPlayer.getX(), 'y':localPlayer.getY()} ));
{#                  ||    #}
{#                  \/    #}
var update = function(keys) {
    var prevX = x, prevY = y;
    if (keys.up)         y -= 2;
    else if (keys.down)  y += 2;
    if (keys.left)       x -= 2;
    else if (keys.right) x += 2;
    return (prevX != x || prevY != y) ? true : false;
};


localPlayer.draw();
{#           ||    #}
{#           \/    #}
var draw = function() {
    var mesh_geometry = new THREE.CubeGeometry( 50, 62, 25 );
    var mesh_material = new THREE.MeshLambertMaterial( { color:0x7777ff} );
    var mesh = new THREE.Mesh(mesh_geometry, mesh_material );
    mesh.translateZ( y );
    mesh.translateX( x );
    scene.add( mesh );
};









//Mesh to align
var material = new THREE.MeshLambertMaterial({color: 0x0000ff});
var cylinder = new THREE.Mesh(new THREE.CylinderGeometry(10, 10, 15), material);
//vector to align to          //x //y //z
var vector = new THREE.Vector3(5, 10, 15);
//create a point to lookAt
var focalPoint = new THREE.Vector3(cylinder.position.x+vector.x,  cylinder.position.y+vector.y,  cylinder.position.z+vector.z );
//all that remains is setting the up vector (if needed) and use lookAt
cylinder.up = new THREE.Vector3(0,0,1);//Z axis up
cylinder.lookAt(focalPoint);


</script>

<!-- ************************************************************ -->
<!-- Share Part -->


</body>
