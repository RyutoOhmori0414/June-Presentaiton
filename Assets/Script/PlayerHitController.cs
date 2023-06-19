using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerHitController : MonoBehaviour
{
    [SerializeField]
    private Transform _rayStart = default;
    [SerializeField]
    private Transform _rayEnd = default;
    [SerializeField]
    private LayerMask _layerMask = default;

    [SerializeField]
    private EnemyController.ShaderType _shader = default;
    public EnemyController.ShaderType Shader
    {
        set => _shader = value;
    }

    private void Update()
    {
        RaycastHit hit;

        Debug.DrawLine(_rayStart.position, _rayEnd.position);

        if (Physics.Linecast(_rayStart.position, _rayEnd.position, out hit, _layerMask) &&
            GameManager.Instance.CustomInputManager.PlayerControl.PlayerActionMap.Fire.WasPressedThisFrame())
        {
            hit.collider.gameObject.GetComponent<EnemyController>().BreakPlay(_shader);
        }
    }
}
