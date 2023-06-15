using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerMoveController : MonoBehaviour
{
    [SerializeField] private float _moveSpeed = 1.0F;
    [SerializeField]
    private Animator _playerAnimator = default;

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
        transform.eulerAngles = new Vector3(0, Camera.main.transform.eulerAngles.y, 0);
        Vector2 InputDir = _playerInput.PlayerActionMap.Move.ReadValue<Vector2>();

        Debug.Log($"{InputDir.x} {InputDir.y}");

        Vector3 moveDir = new Vector3(InputDir.x, 0, InputDir.y);

        moveDir = Camera.main.transform.TransformDirection(moveDir);
        moveDir *= _moveSpeed;
        moveDir.y = Physics.gravity.y;

        _characterController.Move(moveDir * Time.deltaTime);

        _playerAnimator.SetFloat("Speed", moveDir.sqrMagnitude);
    }
}
