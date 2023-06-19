using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveItem : ItemBase
{
    [SerializeField]
    private Shader _dissolve = default;

    public override void Action()
    {
        FindObjectOfType<PlayerHitController>().Shader = EnemyController.ShaderType.DISSOLVE;
    }
}
