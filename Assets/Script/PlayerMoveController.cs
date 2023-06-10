using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMoveController : MonoBehaviour
{
    [SerializeField] private float _moveSpeed = 1.0F;

    private CharacterController _characterController = default;
    private PlayerControl _playerInput = default;
    private void Awake()
    {
        _characterController = GetComponent<CharacterController>();
        _playerInput = new PlayerControl();
        _playerInput.Enable();
    }

    private void Update()
    {
        Vector2 moveDir = _playerInput.PlayerActionMap.Move.ReadValue<Vector2>() * Time.deltaTime * _moveSpeed;
        
        _characterController.Move(new Vector3(moveDir.x + Physics.gravity.x, Physics.gravity.y , -moveDir.y + Physics.gravity.z));
    }
}
