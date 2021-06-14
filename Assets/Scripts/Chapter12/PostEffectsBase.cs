using UnityEngine;
using System.Collections;

//所有屏幕后处理效果都需要绑定在某个摄像机上，并且我们希望在编辑器状态下也可以执行该脚本来查看效果
[ExecuteInEditMode]
[RequireComponent (typeof(Camera))]
public class PostEffectsBase : MonoBehaviour {

	// 为了提前检查各种资源和条件是否满足，我们在Start函数中调用CheckResources函数
	//一些屏幕特效可能需要更多的设置，例如设置一些默认值等，可以重载Start、CheckResources或CheckSupport函数。
	protected void CheckResources() {
		bool isSupported = CheckSupport();
		
		if (isSupported == false) {
			NotSupported();
		}
	}

	// Called in CheckResources to check support on this platform
	protected bool CheckSupport() {
		if (SystemInfo.supportsImageEffects == false) {
			Debug.LogWarning("This platform does not support image effects.");
			return false;
		}
		
		return true;
	}

	// Called when the platform doesn't support this effect
	protected void NotSupported() {
		enabled = false;
	}
	
	protected void Start() {
		CheckResources();
	}

	//由于每个屏幕后处理效果通常都需要指定一个Shader来创建一个用于处理渲染纹理的材质，因此基类中也提供了这样的方法
	//第一个参数指定了该特效需要使用的Shader，第二个参数则是用于后期处理的材质。该函数首先检查Shader的可用性，检查通过后就返回一个使用了该Shader的材质，否则返回null
	protected Material CheckShaderAndCreateMaterial(Shader shader, Material material) {
		if (shader == null) {
			return null;
		}
		
		if (shader.isSupported && material && material.shader == shader)
			return material;
		
		if (!shader.isSupported) {
			return null;
		}
		else {
			material = new Material(shader);
			material.hideFlags = HideFlags.DontSave;
			if (material)
				return material;
			else 
				return null;
		}
	}
}
