	<!-- _______________________________ Libraries ______________________________ -->

	<haxelib name="flixel" version="5.6.1"/>
	<haxelib name="flixel-addons" version="3.2.2"/>
	<haxelib name="tjson" version="1.4.0"/>
	<haxelib name="grig.audio"/>
	<haxelib name="funkin.vis"/>

	<!--Psych stuff needed-->
	<haxelib name="linc_luajit" if="LUA_ALLOWED"/>
	<haxelib name="hscript-iris" if="HSCRIPT_ALLOWED" version="1.0.2"/>
	<haxelib name="hxvlc" if="VIDEOS_ALLOWED"/>
	<haxelib name="hxdiscord_rpc" if="DISCORD_ALLOWED"/>
	<haxelib name="flxanimate"/>

	<!-- Disable Discord IO Thread -->
	<haxedef name="DISCORD_DISABLE_IO_THREAD" if="hxdiscord_rpc" />
	<haxedef name="NO_PRECOMPILED_HEADERS" if="linux" />

	<!-- Enables a terminal log prompt on debug builds -->
	<haxelib name="hxcpp-debug-server" if="debug"/>
	<haxedef name="HXC_LIBVLC_LOGGING" if="VIDEOS_ALLOWED debug" />
	
	<!-- ______________________________ Haxedefines _____________________________ -->

	<!--Enable the Flixel core recording system-->
	<!--<haxedef name="FLX_RECORD" />-->

	<!--Disable the right and middle mouse buttons-->
	<!-- <haxedef name="FLX_NO_MOUSE_ADVANCED" /> -->

	<!--Disable the native cursor API on Flash-->
	<!--<haxedef name="FLX_NO_NATIVE_CURSOR" />-->

	<!--Optimise inputs, be careful you will get null errors if you don't use conditionals in your game-->
	<!-- <haxedef name="FLX_NO_MOUSE" if="mobile" /> -->
	<!-- <haxedef name="FLX_NO_KEYBOARD" if="mobile" /> -->
	<!-- <haxedef name="FLX_NO_TOUCH" if="desktop" /> -->
	<!--<haxedef name="FLX_NO_GAMEPAD" />-->

	<!--Disable the Flixel core sound tray-->
	<!--<haxedef name="FLX_NO_SOUND_TRAY" />-->

	<!--Disable the Flixel sound management code-->
	<!--<haxedef name="FLX_NO_SOUND_SYSTEM" />-->

	<!--Disable the Flixel core focus lost screen-->
	<haxedef name="FLX_NO_FOCUS_LOST_SCREEN" />
	
	<!-- Show debug traces for hxCodec -->
	<haxedef name="HXC_DEBUG_TRACE" if="debug" />
	
	<!--Disable the Flixel core debugger. Automatically gets set whenever you compile in release mode!-->
	<haxedef name="FLX_NO_DEBUG" unless="debug" />

	<!--Enable this for Nape release builds for a serious peformance improvement-->
	<haxedef name="NAPE_RELEASE_BUILD" unless="debug" />
	
	<!--Used for Izzy Engine's crash handler-->
	<haxedef name="HXCPP_CHECK_POINTER" if="CRASH_HANDLER" />
	<haxedef name="HXCPP_STACK_LINE" if="CRASH_HANDLER" />
	<haxedef name="HXCPP_STACK_TRACE" if="CRASH_HANDLER" />
	
	<!--Disable deprecated warnings-->
	<haxedef name='no-deprecation-warnings' />

	<!-- Haxe 4.3.0+: Enable pretty syntax errors and stuff. -->
	<!-- pretty (haxeflixel default), indent, classic (haxe compiler default) -->
	<haxedef name="message.reporting" value="pretty" />

	<!--Macro fixes-->
	<haxeflag name="--macro" value="allowPackage('flash')" />
	<haxeflag name="--macro" value="include('my.pack')" />
