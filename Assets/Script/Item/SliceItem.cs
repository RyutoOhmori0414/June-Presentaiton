using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SliceItem : ItemBase
{
    [SerializeField]
    private Shader _Slice = default;

    public override void Action()
    {
        FindObjectOfType<PlayerHitController>().Shader = EnemyController.ShaderType.SLICE;
    }
}
