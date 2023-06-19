using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using UnityEngine.Rendering;
using Cysharp.Threading.Tasks;
using DG.Tweening;

public class EnemyController : MonoBehaviour
{
    [SerializeField]
    private List<SkinnedMeshRenderer> _renderers;
    private readonly int _amountId = Shader.PropertyToID("_Amount");
    private readonly int _effectId = Shader.PropertyToID("_Effect");

    private string _currentKeyword = "";

    private bool _isPlaying = false;

    [System.Serializable]
    public enum ShaderType
    {
        DISSOLVE,
        GEOMETRY,
        SLICE
    }

    private void Awake()
    {
        _currentKeyword = "_EFFECT_" + ShaderType.DISSOLVE.ToString();

        _renderers = new List<SkinnedMeshRenderer>(GetComponentsInChildren<SkinnedMeshRenderer>());

        foreach (var renderer in _renderers)
        {
            var temp = new Material(renderer.material);
            temp.CopyPropertiesFromMaterial(renderer.material);

            renderer.material = temp;
        }
    }

    public void BreakPlay(ShaderType shaderType)
    {
        if (_isPlaying) return;

        _isPlaying = true;

        var temp = "_EFFECT_" + shaderType.ToString();

        for (int i = 0; i < _renderers.Count; i++)
        {
            _renderers[i].material.DisableKeyword(_currentKeyword);
            _renderers[i].material.SetFloat(_effectId, (int)shaderType);

            _renderers[i].material.EnableKeyword(temp);
        }

        _currentKeyword = temp;

        Break(this.GetCancellationTokenOnDestroy());
    }

    private async void Break(CancellationToken token)
    {
        await DOTween.To(() => 0F, UpdateValue, 1F, 3F);
        Destroy(gameObject);
    }

    private void UpdateValue(float value)
    {
        for (int i = 0; i < _renderers.Count; i++)
        {
            _renderers[i].material.SetFloat(_amountId, value);
        }
    }
}