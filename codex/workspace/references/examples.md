# Examples

These examples show some preferred coding patterns.

## Interface and Impl structure

```go
type ReleaseService interface {
	GetCurrentReleaseTag() (string, error)
	GitRelease() error
	GitAndDockerRelease(imageName string) error
}

type ReleaseServiceImpl struct {
	gitReleaseClient GitReleaseClient
	dockerClient     DockerClient
	clockClient      ClockClient
}

func (r *ReleaseServiceImpl) GitRelease() error {
	newTag, err := r.gitReleaseClient.GetValidatedNewTag()
	if err != nil {
		return err
	}
	return r.gitReleaseClient.RunGitRelease(newTag)
}
```

Concepts shown:

- interface named by role
- implementation named with `Impl`
- dependencies injected via interfaces
- implementation methods on pointer receivers
- simple pass-through `return err` path that usually does not need its own dedicated unit test case

## Test dependency setup

```go
type releaseServiceTestDependencies struct {
	service          ReleaseService
	serviceImpl      *ReleaseServiceImpl
	gitReleaseClient *GitReleaseClientMock
	dockerClient     *DockerClientMock
	clockClient      *ClockClientMock
}

func setupReleaseServiceTestDependencies(t *testing.T) *releaseServiceTestDependencies {
	gitReleaseClient := NewGitReleaseClientMock(t)
	dockerClient := NewDockerClientMock(t)
	clockClient := NewClockClientMock(t)
	serviceImpl := &ReleaseServiceImpl{
		gitReleaseClient: gitReleaseClient,
		dockerClient:     dockerClient,
		clockClient:      clockClient,
	}

	return &releaseServiceTestDependencies{
		service:          serviceImpl,
		serviceImpl:      serviceImpl,
		gitReleaseClient: gitReleaseClient,
		dockerClient:     dockerClient,
		clockClient:      clockClient,
	}
}
```

Concepts shown:

- explicit dependency bundle for tests
- generated mocks consumed by the test, not written by hand
- both interface and concrete impl available when needed

## Table-driven tests and error assertions

```go
testCases := []struct {
	name        string
	serviceMap  map[string]any
	expectedMsg string
	errorArgs   []any
}{
	{"no volumes", map[string]any{}, "", nil},
	{"named volume string", map[string]any{"volumes": []string{"maint_app_data:/data"}}, "", nil},
	{"host path string", map[string]any{"volumes": []string{"/host/path:/data"}}, hostDirectoriesMountedForbidden, []any{ServiceField, "svc"}},
}

for _, testCase := range testCases {
	t.Run(testCase.name, func(t *testing.T) {
		err := serviceValidator.ValidateServiceVolumes("maint", "app", "svc", testCase.serviceMap)
		if testCase.expectedMsg == "" {
			assert.Nil(t, err)
			return
		}
		deepstack.AssertDeepStackError(t, err, testCase.expectedMsg, testCase.errorArgs...)
	})
}
```

Concepts shown:

- `common/assert` for standard assertions
- `deepstack.AssertDeepStackError` for rich error checks
- compact setup that focuses on behavior

## Wire build graph

```go
type Dependencies struct {
	LicenseHandler *LicenseHandlerImpl
	DatabaseClient DatabaseClient
	TokenIssuer    TokenIssuer
	PaddleClient   PaddleClient
}

func BuildDependencyGraph() *Dependencies {
	wire.Build(
		wire.Struct(new(Dependencies), "*"),
		wire.Struct(new(LicenseHandlerImpl), "*"),
		wire.Struct(new(LicenseServiceImpl), "*"),
		wire.Bind(new(LicenseService), new(*LicenseServiceImpl)),
	)
	return nil
}
```

Concepts shown:

- human-edited `build.go`
- explicit interface-to-implementation binding
- composition at the boundary rather than inside business logic
