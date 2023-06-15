using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class TitleLogoAnimCallBack : MonoBehaviour
{
    [SerializeField]
    UnityEvent _visibleAnimCallBack = default;

    public void VisibleAnim()
    {
        _visibleAnimCallBack.Invoke();
    }
}
