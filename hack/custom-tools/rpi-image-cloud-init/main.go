package main

import (
	"context"
	"flag"
	"fmt"
	"github.com/cheggaaa/pb"
	"github.com/diskfs/go-diskfs"
	"github.com/diskfs/go-diskfs/filesystem"
	"github.com/hashicorp/go-getter"
	"io"
	"io/ioutil"
	"os"
	"path/filepath"
	"sync"
)

type CommandOptions struct {
	ImageFileLocation        string
	BootConfigFolderLocation string
	DownloadDefaultImage     bool
}

var (
	cmdOptions                      CommandOptions
	defaultUbuntuImageUrl           = "https://cdimage.ubuntu.com/releases/20.04/release/ubuntu-20.04.3-preinstalled-server-arm64+raspi.img.xz"
	defaultImageFileLocation        = "/tmp/ubuntu-pi.img"
	defaultBootConfigFolderLocation = "./boot/"
)

func main() {

	flag.StringVar(
		&cmdOptions.ImageFileLocation,
		"image-file",
		defaultImageFileLocation,
		"Absolute path to the ubuntu preinstalled cloud image for raspberry pi (.img)",
	)
	flag.StringVar(
		&cmdOptions.BootConfigFolderLocation,
		"boot-configs",
		defaultBootConfigFolderLocation,
		"Absolute path to the folder containing custom boot partition files",
	)
	flag.BoolVar(
		&cmdOptions.DownloadDefaultImage,
		"download-default",
		false,
		"Set true if you want to download the default ubuntu image first",
	)
	flag.Parse()

	if cmdOptions.DownloadDefaultImage {
		client := &getter.Client{
			Ctx:              context.Background(),
			Dst:              cmdOptions.ImageFileLocation,
			Dir:              false,
			Src:              defaultUbuntuImageUrl,
			Mode:             getter.ClientModeFile,
			ProgressListener: &ProgressBar{},
		}
		if err := client.Get(); err != nil {
			panic(err)
		}
	}

	disk, err := diskfs.Open(cmdOptions.ImageFileLocation)
	if err != nil {
		panic(err)
	}
	fs, err := disk.GetFilesystem(1)
	if err != nil {
		panic(err)
	}

	if fileInfo, err := fs.ReadDir("/"); err != nil {
		panic(err)
	} else {
		for _, file := range fileInfo {
			fmt.Println(file.Name())
		}
	}

	if dir, err := fs.ReadDir("/"); err != nil {
		panic(err)
	} else {
		for _, file := range dir {
			if _, err := fs.OpenFile(file.Name(), os.O_RDONLY); err != nil {
				panic(fmt.Errorf("this dumb ass shit: %s, %s", file.Name(), err))
			}
		}
	}

	bootDir, err := ioutil.ReadDir(cmdOptions.BootConfigFolderLocation)
	if err != nil {
		panic(err)
	}
	for _, file := range bootDir {
		if err := OpenAndCopy(file.Name(), cmdOptions.BootConfigFolderLocation, fs); err != nil {
			panic(err)
		}
	}
}

func OpenAndCopy(fileName, bootConfigFolderLocation string, fs filesystem.FileSystem) error {
	src, err := os.OpenFile(filepath.Join(bootConfigFolderLocation, fileName), os.O_RDONLY, 0777)
	if err != nil {
		return fmt.Errorf("failure opening real file: %s, %s", fileName, err)
	}

	dest, err := fs.OpenFile(filepath.Join("/", fileName), os.O_RDWR)
	if err != nil {
		return fmt.Errorf("failure opening file from image: %s, %s", fileName, err)
	}
	if written, err := io.Copy(dest, src); err != nil {
		return fmt.Errorf("copy interrupted for %s at %d, %s", fileName, written, err)
	}
	return nil
}

// ProgressBar wraps a github.com/cheggaaa/pb.Pool
// in order to display download progress for one or multiple
// downloads.
//
// If two different instance of ProgressBar try to
// display a progress only one will be displayed.
// It is therefore recommended to use DefaultProgressBar
type ProgressBar struct {
	// lock everything below
	lock sync.Mutex

	pool *pb.Pool

	pbs int
}

func ProgressBarConfig(bar *pb.ProgressBar, prefix string) {
	bar.SetUnits(pb.U_BYTES)
	bar.Prefix(prefix)
}

// TrackProgress instantiates a new progress bar that will
// display the progress of stream until closed.
// total can be 0.
func (cpb *ProgressBar) TrackProgress(src string, currentSize, totalSize int64, stream io.ReadCloser) io.ReadCloser {
	cpb.lock.Lock()
	defer cpb.lock.Unlock()

	newPb := pb.New64(totalSize)
	newPb.Set64(currentSize)
	ProgressBarConfig(newPb, filepath.Base(src))
	if cpb.pool == nil {
		cpb.pool = pb.NewPool()
		cpb.pool.Start()
	}
	cpb.pool.Add(newPb)
	reader := newPb.NewProxyReader(stream)

	cpb.pbs++
	return &readCloser{
		Reader: reader,
		close: func() error {
			cpb.lock.Lock()
			defer cpb.lock.Unlock()

			newPb.Finish()
			cpb.pbs--
			if cpb.pbs <= 0 {
				cpb.pool.Stop()
				cpb.pool = nil
			}
			return nil
		},
	}
}

type readCloser struct {
	io.Reader
	close func() error
}

func (c *readCloser) Close() error { return c.close() }
