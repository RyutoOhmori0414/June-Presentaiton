using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using Cinemachine;
using System.Threading;
using Cysharp.Threading.Tasks;

public class TitleController : MonoBehaviour
{
    [SerializeField]
    private PlayableDirector _timeline = default;
    [SerializeField, Tooltip("TitleのVCam")]
    private CinemachineVirtualCameraBase _titleVCam = default;
    [SerializeField, Tooltip("PlayerのVCam")]
    private CinemachineVirtualCameraBase _playerVCam = default;
    private bool _startEffectEnded = false;

    public bool StartEffectEnded
    {
        set => _startEffectEnded = value;
    }

    private void Start()
    {
        var cancellationToken = this.GetCancellationTokenOnDestroy();
        TitleStart(cancellationToken);
    }

    private async void TitleStart(CancellationToken token)
    {
        // アニメーションをが終わるのを待つ
        await UniTask.WaitUntil(() => _startEffectEnded, cancellationToken: token);
        // 入力を待つ
        await UniTask.WaitUntil(GameManager.Instance.CustomInputManager.AnyButton.IsPressed, cancellationToken: token);

        _timeline.Play();
    }

    public void TitleChangeCameraPriority()
    {
        (_playerVCam.Priority, _titleVCam.Priority) = (_titleVCam.Priority, _playerVCam.Priority);
    }
}
